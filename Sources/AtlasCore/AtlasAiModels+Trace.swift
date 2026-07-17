import Foundation

/// Trace + tool-event DTOs — peel de `AtlasAiModels.swift` (régua ~100).

/// O que `createAiInteraction`/`getAiInteraction` retornam. Campos escalares do
/// centro; o grafo pesado (router_decision, atlas_decision, decision_receipt,
/// quality_evaluation, attempt_history) fica em `metadata`/porta depois.
public struct AtlasAiTrace: Codable, Sendable, Identifiable {
    public let id: String
    public let traceKey: String
    public let threadId: String?
    public let sessionId: String?
    public let status: String
    public let operatorInput: String
    public let intent: String?
    public let agentSlug: String
    public let provider: String?
    public let model: String?
    public let responseText: String?
    public let latencyMs: Int?
    public let completedAt: String?
    public let metadata: JSONObject?
    // Execução — a "orquestra" (jobs = agentes/providers/modelos) + o estágio do
    // Atlas Decide. Ligados para a Ribbon de Execução (transparência agêntica).
    public let jobs: [AtlasAiJob]?
    public let atlasDecideExecution: AtlasAiExecutionState?
    public let routerDecision: AtlasAiRouterDecision?
    public let atlasDecision: AtlasAiDecision?
    public let decisionReceipt: AtlasAiDecisionReceipt?
    public let qualityEvaluation: AtlasAiQualityEvaluation?
    public let qualityActions: [AtlasAiQualityAction]?
    public let toolEvents: [AtlasAiToolEvent]?
    /// Ledger ordenado do que aconteceu durante a execução. É decodificado no
    /// snapshot para que a timeline sobreviva ao stream, reload e relaunch.
    public let streamEvents: [AtlasAiStreamEvent]?
    public let metricSummary: JSONObject?
    public let createdAt: String
    public let updatedAt: String
}

public struct AtlasAiToolEvent: Codable, Sendable, Identifiable {
    public let id: String
    /// Campos legados continuam opcionais porque o resource mobile atual
    /// publica apenas o receipt seguro e necessário à apresentação.
    public let eventKey: String?
    public let traceId: String?
    public let sessionId: String?
    public let threadId: String?
    public let tool: String
    /// Categoria canônica calculada pelo servidor (`read`, `write`, `bash`…).
    public let kind: String?
    public let risk: String?
    public let permissionStatus: String?
    public let approvalSource: String?
    public let inputSummary: JSONObject?
    public let outputSummary: JSONObject?
    public let changedFiles: [JSONValue]?
    public let checkpointId: String?
    public let exitCode: Int?
    public let durationMs: Int?
    public let error: String?
    public let occurredAt: String?
    public let createdAt: String?
}
