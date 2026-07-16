import Foundation

// Tipos de decisão pinados por `AtlasAiTrace` (routerDecision / atlasDecision /
// decisionReceipt). As rotas admin list/preview foram podadas em F0.3 — 0
// consumidores de produto. Uniões abertas de provider e decision_mode ficam
// String (enum estrito quebraria o decode num valor novo).

/// `router_decision` cru: a saída do roteador antes de virar AtlasDecision auditado.
public struct AtlasAiRouterDecision: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let mode: String
    public let selectedProvider: String?
    public let fallbackProvider: String?
    public let signals: JSONObject?
    public let reason: String
    public let wasOverridden: Bool
    public let createdAt: String?
    public let updatedAt: String?
}

/// Recibo de decisão embutido no trace (`decision_receipt`). Tudo opcional:
/// o servidor monta o receipt por partes conforme a rota resolve.
public struct AtlasAiDecisionReceipt: Codable, Sendable, Equatable {
    public let decisionId: String?
    public let traceId: String?
    public let schemaVersion: Int?
    public let decisionMode: String?
    public let candidateProvider: String?
    public let selectedProvider: String?
    public let selectedModel: String?
    public let fallbackProvider: String?
    public let fallbackReason: String?
    public let operatorRequestedProvider: String?
    public let requestedProvider: String?
    public let wasOverridden: Bool?
    public let reason: String?
    public let signals: JSONObject?
    public let candidates: [JSONValue]?
    public let constraints: JSONObject?
    public let metricsSnapshot: JSONObject?
    public let taskProfile: JSONObject?
    public let contextStrategy: String?
    public let executionStrategy: String?
    public let executionGraph: JSONObject?
}

/// O AtlasDecision persistido/auditado no trace. id não-nulo → Identifiable.
public struct AtlasAiDecision: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let traceId: String?
    public let routerDecisionId: String?
    public let policyVersion: String
    public let decisionMode: String
    public let routeMode: String?
    public let taskType: String?
    public let riskLevel: String?
    public let contextStrategy: String?
    public let executionStrategy: String?
    public let selectedProvider: String?
    public let selectedModel: String?
    public let fallbackProvider: String?
    public let operatorRequestedProvider: String?
    public let requestedProvider: String?
    public let wasOverridden: Bool
    public let confidenceScore: Double?
    public let signals: JSONObject?
    public let candidates: [JSONValue]?
    public let constraints: JSONObject?
    public let metricsSnapshot: JSONObject?
    public let taskProfile: JSONObject?
    public let executionGraph: JSONObject?
    public let reason: String
    public let createdAt: String?
    public let updatedAt: String?
}
