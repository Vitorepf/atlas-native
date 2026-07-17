import SwiftUI
import AtlasCore
import AtlasImaging

/// Envio de turno, execução do stream e recuperação de outbox — fora do arquivo
/// principal para ConversationModel ficar sob a régua (<550).
@MainActor
extension ConversationModel {
    @discardableResult
    func sendTurn(
        _ text: String,
        effort: AtlasComputeEffort,
        drainQueueOnSuccess: Bool,
        queuedMessageId: QueuedMessage.ID? = nil
    ) async -> Bool {
        var trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Follow-up de texto durante execução: entra na fila imediatamente e
        // não espera upload/preparação nem tenta competir com o stream atual.
        if isSending || activeRun != nil {
            await queue(text: trimmed)
            return false
        }

        await finishPendingAttachmentPreparations()
        let sendingDrafts = drafts
        // Só anexos, sem texto → prompt sintético (paridade com o RN)
        if trimmed.isEmpty && !sendingDrafts.isEmpty {
            trimmed = "analise \(sendingDrafts.count == 1 ? "o anexo enviado" : "os \(sendingDrafts.count) anexos enviados")"
        }
        guard !trimmed.isEmpty else { return false }

        // C4: input_text do servidor tem teto e não é o lugar de transportar
        // uma obra inteira. O Core externaliza >40k como UM Markdown canônico;
        // a bolha local continua mostrando exatamente o que o operador escreveu.
        let originalText = trimmed
        let existingTextFiles = sendingDrafts.filter { $0.kind == .text || $0.kind == .code }.count
        let longMessage: AtlasPreparedLongMessage
        do {
            longMessage = try AtlasLongMessage.prepare(
                originalText, existingTextFileCount: existingTextFiles
            )
        } catch {
            toast = String(describing: error)
            return false
        }
        trimmed = longMessage.inputText
        isSending = true

        bubbles.append(ChatBubble(id: "local-user-\(bubbles.count)", role: "user", text: originalText))
        let aid = "local-assistant-\(bubbles.count)"
        bubbles.append(ChatBubble(id: aid, role: "assistant", text: "", streaming: true, startedAt: Date()))

        // 1. Upload dos anexos ANTES do create (chunked + resume + sha via engine).
        var fields: RichInputInteractionFields? = nil
        if !sendingDrafts.isEmpty || longMessage.attachment != nil {
            for i in drafts.indices { drafts[i].state = .subindo }
            do {
                var inputs = sendingDrafts.compactMap { attachmentInputs[$0.id] }
                if let attachment = longMessage.attachment { inputs.append(attachment) }
                let images = inputs.filter { $0.kind == .image }
                let documents = inputs.filter { $0.kind != .image }
                let uploaded = try await engine.uploadAll(
                    images: images, documents: documents,
                    progress: { [weak self] p in
                        Task { @MainActor [weak self] in
                            self?.uploadPercent = p.phase == .complete ? nil : p.percent
                        }
                    })
                fields = engine.interactionFields(images: uploaded.images,
                                                  documents: uploaded.documents,
                                                  inputText: trimmed)
                drafts.removeAll(); attachmentInputs.removeAll()
                uploadPercent = nil
            } catch {
                for i in drafts.indices { drafts[i].state = .falhou("\(error)") }
                uploadPercent = nil
                update(aid) { $0.text = "⚠️ upload falhou: \(error)"; $0.streaming = false }
                isSending = false
                return false
            }
        }

        var completedSuccessfully = false
        do {
            #if DEBUG
            let proofProvider = ProcessInfo.processInfo.environment["ATLAS_DEVICE_PROOF_PROVIDER"]
            #else
            let proofProvider: String? = nil
            #endif
            // Fatos antes da pergunta: quem lê o git é o determinístico, quem
            // entende é o agente. Sem isto o agente opina sobre commits que não
            // existem; com isto ele não tem como inventar. A bolha local não
            // muda — o operador vê a própria frase, não o dossiê.
            var wireText = trimmed
            var operatorText: String?
            if let collectFacts = turnFacts,
               let facts = await collectFacts(originalText),
               !facts.isEmpty {
                wireText = facts + "\n\n" + trimmed
                // Quem sabe o que o operador DIGITOU é esta tela, e ela tem de
                // dizer: sem isto o Atlas aprende "regras do operador" lendo o
                // dossiê que a própria máquina anexou — e grava a prosa dela
                // como se fosse a voz dele. Medido: 8 de 13 sinais de
                // aprendizado eram frases que o operador nunca escreveu.
                operatorText = originalText
            }
            // Payload do turno: read-only por padrão, task_type declarado pela
            // superfície, esforço só quando ≠ auto, workspace real e metadata de
            // long message. A política mobile/Hermes continua aplicada abaixo.
            let workspace = workspaceSlug.map {
                TurnPayloadBuilder.Workspace(slug: $0, name: workspaceName, path: workspacePath)
            }
            let payload = TurnPayloadBuilder.build(
                taskKind: taskKind,
                effort: effort,
                workspace: workspace,
                longMessage: longMessage.metadata,
                operatorText: operatorText
            )
            let input = CreateAiInteractionInput(inputText: wireText,
                                                 clientId: UUID().uuidString.lowercased(),
                                                 threadId: threadId?.rawValue,
                                                 newThread: threadId == nil ? true : nil,
                                                 agentSlug: proofProvider == nil ? nil : "atlas",
                                                 provider: proofProvider,
                                                 sourceType: "app",
                                                 payload: atlasMobileInteractionPayload(base: payload),
                                                 uploadedImages: fields?.uploadedImages.isEmpty == false ? fields?.uploadedImages : nil,
                                                 uploadedDocuments: fields?.uploadedDocuments.isEmpty == false ? fields?.uploadedDocuments : nil,
                                                 richInputPayload: fields?.richInputPayload)
            completedSuccessfully = try await execute(
                input,
                assistantId: aid,
                queuedMessageId: queuedMessageId
            )
        } catch {
            apply(error, to: aid)
        }
        activeRun = nil
        isSending = false
        if completedSuccessfully && drainQueueOnSuccess {
            await drainQueuedMessages()
        }
        return completedSuccessfully
    }

    func recoverPendingIfNeeded() async {
        guard activeRun == nil, !isSending else { return }
        let pending = await outbox.pending()
        guard let input = pending.first(where: {
            if let threadId { return $0.threadId == threadId.rawValue }
            return $0.threadId == nil
        }) else { return }

        // Se o relaunch carregou uma thread já finalizada, não duplica a bolha.
        if let clientId = input.clientId,
           let trace = try? await client.findInteraction(clientId: ClientID(clientId)),
           trace.trace.turnStatus.isTerminal,
           bubbles.contains(where: { $0.traceId == TraceID(trace.trace.id) }) {
            try? await outbox.remove(clientId: clientId)
            return
        }

        if !bubbles.suffix(2).contains(where: { $0.role == "user" && $0.text == input.inputText }) {
            bubbles.append(ChatBubble(id: "recovered-user-\(input.clientId ?? UUID().uuidString)",
                                      role: "user", text: input.inputText))
        }
        let aid = "recovered-assistant-\(input.clientId ?? UUID().uuidString)"
        bubbles.append(ChatBubble(id: aid, role: "assistant", text: "", streaming: true, startedAt: Date()))
        isSending = true
        do {
            let queuedMessageId: String?
            if let clientId = input.clientId {
                queuedMessageId = await outbox.followUpId(clientId: clientId)
            } else {
                queuedMessageId = nil
            }
            let completedSuccessfully = try await execute(
                input,
                assistantId: aid,
                queuedMessageId: queuedMessageId
            )
            activeRun = nil
            isSending = false
            if completedSuccessfully { await drainQueuedMessages() }
        } catch {
            apply(error, to: aid)
        }
        activeRun = nil
        isSending = false
    }

    private func execute(
        _ input: CreateAiInteractionInput,
        assistantId: String,
        queuedMessageId: QueuedMessage.ID? = nil
    ) async throws -> Bool {
        let run = InteractionRun(transport: client, outbox: outbox)
        activeRun = run
        var live = ""
        var completedSuccessfully = false
        for try await event in await run.start(input: input, followUpId: queuedMessageId) {
            switch event {
            case .persisted(let followUpId):
                if let followUpId {
                    await consumeQueuedMessageAfterPersistence(id: followUpId)
                }
            case .created(let trace):
                if let canonicalThreadId = trace.threadId.map({ ThreadID($0) }), threadId != canonicalThreadId {
                    threadId = canonicalThreadId
                    await adoptQueueScope(threadId: canonicalThreadId)
                }
                update(assistantId) { $0.traceId = TraceID(trace.id); $0.provider = trace.provider }
                applyExecution(assistantId, trace)
                Task { await AtlasSession.rhythm.recordActivity(workspace: workspaceName ?? workspaceSlug) }
            case .activity(let activity):
                update(assistantId) {
                    $0.reconnectNotice = nil
                    $0.activities = atlasMergeAgentActivities(
                        existing: $0.activities,
                        incoming: [activity]
                    )
                }
            case .content(let frame):
                guard atlasShouldRenderAssistantContent(frame),
                      let visible = atlasVisibleAssistantText(frame.content) else { continue }
                live = frame.type == "response" ? visible : live + visible
                update(assistantId) { $0.text = live; $0.streaming = true }
            case .execution(let snapshot):
                applyExecution(
                    assistantId,
                    snapshot.trace,
                    projectedStreamActivities: snapshot.projectedActivities
                )
            case .reconnecting(let lastSequence, let attempt):
                update(assistantId) {
                    $0.reconnectNotice = "Reconectando ao stream · tentativa \(attempt) · após evento \(lastSequence)"
                }
            case .suspended(let trace):
                complete(assistantId, trace: trace)
                AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
            case .remoteError(let payload):
                let message = payload["message"]?.stringValue ?? "erro no stream"
                update(assistantId) { if $0.text.isEmpty { $0.text = "⚠️ \(message)" } }
            case .completed(let done, let finalTrace):
                complete(assistantId, trace: finalTrace)
                completedSuccessfully = done.turnStatus == .succeeded
                AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
            }
        }
        activeRun = nil
        return completedSuccessfully
    }

    private func apply(_ error: Error, to id: String) {
        update(id) {
            if $0.text.isEmpty { $0.text = "⚠️ \(atlasUserMessage(for: error))" }
            $0.streaming = false
        }
        toast = atlasUserMessage(for: error)
    }
}
