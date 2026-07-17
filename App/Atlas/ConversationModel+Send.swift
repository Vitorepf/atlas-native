import SwiftUI
import AtlasCore
import AtlasImaging

/// Envio de turno — fora do arquivo principal para ConversationModel ficar sob a régua (<550).
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
}
