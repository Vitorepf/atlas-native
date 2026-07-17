import Foundation
import AtlasCore

/// Projeção de execução — history: ConversationModel+ExecutionHistory.swift
@MainActor
extension ConversationModel {
    var currentExecutionPresence: AtlasExecutionPresence? {
        currentPresenceBubble?.executionPresence
    }

    var currentExecutionPresenceTraceId: TraceID? {
        currentPresenceBubble?.traceId
    }

    private var currentPresenceBubble: ChatBubble? {
        bubbles.reversed().first { bubble in
            bubble.traceId != nil && bubble.executionPresence?.isOngoing == true
        }
    }

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
