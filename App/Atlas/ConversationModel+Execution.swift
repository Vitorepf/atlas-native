import Foundation
import AtlasCore

/// Projeção de execução (presença, histórico, escolha/retry) — fora do arquivo
/// principal para ConversationModel ficar sob a régua (<800).
@MainActor
extension ConversationModel {
    /// Fonte única para Lock Screen e Dynamic Island. Inclui espera durável
    /// confirmada pelo servidor mesmo depois que a conexão SSE da tentativa
    /// fechou; a casca não deve inventar uma fase nesse intervalo.
    var currentExecutionPresence: AtlasExecutionPresence? {
        currentPresenceBubble?.executionPresence
    }

    /// Identidade canônica da mesma presença. A casca usa-a como chave da Live
    /// Activity para não criar uma sessão nova ao transitar de stream para uma
    /// pausa aguardando decisão ou sistema externo.
    var currentExecutionPresenceTraceId: TraceID? {
        currentPresenceBubble?.traceId
    }

    private var currentPresenceBubble: ChatBubble? {
        bubbles.reversed().first { bubble in
            bubble.traceId != nil && bubble.executionPresence?.isOngoing == true
        }
    }

    // MARK: - Execução

    /// O endpoint de lista é deliberadamente leve e não inclui `stream_events`.
    /// Busca os snapshots completos em paralelo para que cada resposta reabra
    /// com sua timeline registrada, inclusive depois de relaunch.
    func loadExecutionHistory() async {
        let refs = bubbles.compactMap { bubble -> (String, TraceID)? in
            guard bubble.role == "assistant", let traceId = bubble.traceId else { return nil }
            return (bubble.id, traceId)
        }
        let client = self.client
        var snapshots: [(String, AtlasAiTrace?)] = []
        // Bounded fan-out: restaura todo o histórico sem disparar dezenas de
        // requests simultâneos contra o servidor ao abrir uma thread longa.
        var cursor = refs.startIndex
        while cursor < refs.endIndex {
            let end = refs.index(cursor, offsetBy: 6, limitedBy: refs.endIndex) ?? refs.endIndex
            let batch = refs[cursor..<end]
            let values = await withTaskGroup(of: (String, AtlasAiTrace?).self) { group in
                for (bubbleId, traceId) in batch {
                    group.addTask {
                        let trace = try? await client.getAiInteraction(traceId)
                        return (bubbleId, trace?.trace)
                    }
                }
                var values: [(String, AtlasAiTrace?)] = []
                for await value in group { values.append(value) }
                return values
            }
            snapshots.append(contentsOf: values)
            cursor = end
        }
        for (bubbleId, trace) in snapshots {
            if let trace { applyExecution(bubbleId, trace) }
        }
    }

    func applyExecution(
        _ id: String,
        _ trace: AtlasAiTrace,
        projectedStreamActivities: [AtlasAgentActivity]? = nil
    ) {
        let agents = (trace.jobs ?? []).map {
            ExecAgent(id: $0.id, agent: $0.agentSlug, provider: $0.provider, model: $0.model, status: $0.status)
        }
        let choiceJob = trace.jobs?.first { $0.turnStatus == .awaitingUserChoice }
        let failedJob = trace.jobs?.first { $0.turnStatus == .failed }
        update(id) {
            $0.agents = agents
            $0.decideStrategy = trace.atlasDecideExecution?.strategy
            $0.decideStage = trace.atlasDecideExecution?.atlasDecideStage
            $0.decisionSummary = trace.decisionSummary
            $0.qualitySummary = trace.qualitySummary
            $0.executionPlan = trace.executionPlan
            $0.diffStats = AtlasTraceGovernance.diffStats(from: trace.metadata)
            $0.planRevisions = AtlasTraceGovernance.planRevisions(from: trace.metadata)
            $0.executionProgress = trace.executionProgress
            $0.executionPresentationState = trace.executionPresentationState
            $0.executionChoiceJobId = choiceJob.map { JobID($0.id) }
            $0.retryableJobId = failedJob.map { JobID($0.id) }
            $0.reconnectNotice = nil
            let fromStream = projectedStreamActivities ?? atlasAgentTimeline(from: trace.streamEvents ?? [])
            let recovered = fromStream + trace.toolActivities
            $0.activities = atlasMergeAgentActivities(existing: $0.activities, incoming: recovered)
        }
    }

    /// Executa uma opção que o próprio servidor declarou para um job pausado.
    /// A View fornece somente ids públicos; o recibo canônico é relido antes de
    /// qualquer mudança visual para não antecipar estado nem duplicar ação.
    func resolveExecutionChoice(jobId: JobID, optionId: String) async {
        do {
            let receipt = try await client.resumeAiJobChoice(jobId.rawValue, optionId: optionId)
            guard let traceId = receipt.job.traceId else {
                toast = "A decisão foi registrada, mas a conversa ainda não está disponível."
                return
            }
            let typedTraceId = TraceID(traceId)
            let refreshed = try await client.getAiInteraction(typedTraceId)
            for bubble in bubbles where bubble.traceId == typedTraceId {
                applyExecution(bubble.id, refreshed.trace)
            }
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }

    /// C17: retoma um turno que FALHOU reenfileirando o job real
    /// (`/ai/jobs/{id}/retry`). Não fabrica estado: relê o trace pelo job
    /// devolvido e reaplica a execução, exatamente como `resolveExecutionChoice`.
    func retryTurn(jobId: JobID) async {
        do {
            let receipt = try await client.retryAiJob(jobId.rawValue)
            guard let traceId = receipt.job.traceId else {
                toast = "O turno foi reenfileirado."
                return
            }
            let typedTraceId = TraceID(traceId)
            let refreshed = try await client.getAiInteraction(typedTraceId)
            for bubble in bubbles where bubble.traceId == typedTraceId {
                applyExecution(bubble.id, refreshed.trace)
            }
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }

    func complete(_ id: String, trace: AtlasAiTrace?) {
        update(id) {
            $0.streaming = false
            $0.agents = []
            $0.decideStage = nil
            $0.reconnectNotice = nil
            if let trace {
                if $0.text.isEmpty, let response = trace.responseText,
                   let visible = atlasVisibleAssistantText(response) { $0.text = visible }
                if $0.text.isEmpty {
                    $0.text = "A execução terminou, mas a resposta continha saída interna e foi ocultada. Tente novamente."
                }
                $0.model = trace.model ?? $0.model
                $0.elapsedMs = trace.latencyMs ?? $0.startedAt.map { Int(Date().timeIntervalSince($0) * 1000) }
            }
        }
    }
}
