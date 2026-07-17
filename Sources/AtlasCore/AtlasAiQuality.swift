import Foundation

// Tipos de qualidade pinados por `AtlasAiTrace` (qualityEvaluation /
// qualityActions). As rotas admin list/run foram podadas em F0.3 — 0
// consumidores de produto. `status`/`action_type`/`provider` ficam String
// (uniões abertas no wire). Checks: AtlasAiQuality+Checks.swift

/// Avaliação de qualidade embutida no trace. Bags pesados vivem como `JSONValue`.
public struct AtlasAiQualityEvaluation: Codable, Sendable, Identifiable {
    public let id: String
    public let traceId: String?
    public let threadId: String?
    public let sessionId: String?
    public let provider: String?
    public let model: String?
    public let agentSlug: String?
    public let evaluatorVersion: String
    public let score: Double
    public let status: String
    public let dimensions: JSONObject?
    public let flags: [JSONValue]?
    public let suggestedActions: [JSONValue]?
    public let metadata: JSONObject?
    public let actions: [AtlasAiQualityAction]?
    public let createdAt: String
    public let updatedAt: String
}

/// Ação de remediação ligada à avaliação. `remediationTrace` referencia
/// `AtlasAiTrace` do loop de conversa.
public struct AtlasAiQualityAction: Codable, Sendable, Identifiable {
    public let id: String
    public let evaluationId: String?
    public let traceId: String?
    public let remediationTraceId: String?
    public let threadId: String?
    public let sessionId: String?
    public let actionType: String
    public let status: String
    public let priority: Int
    public let reason: String
    public let flags: [JSONValue]?
    public let payload: JSONObject?
    public let result: JSONObject?
    public let errorMessage: String?
    public let dedupeKey: String?
    public let completedAt: String?
    public let remediationTrace: AtlasAiTrace?
    public let createdAt: String
    public let updatedAt: String
}
