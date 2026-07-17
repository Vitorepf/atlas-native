import Foundation

// O centro do Atlas AI: o loop de conversa (threads → messages → sessions →
// trace) portado de lib/api/atlasAi.ts. O decoder usa `.convertFromSnakeCase`,
// então snake_case do servidor vira camelCase aqui sem CodingKeys. Todo campo
// que o servidor pode mandar `null` é opcional — senão o decode quebra.
//
// Clusters admin (telemetry/policies/providers/attachments) foram podados em
// F0 — 0 consumidores de produto. Isto é o loop que o operador realmente usa.

/// `AtlasAiProvider | string` no TS é uma união aberta — o servidor pode mandar
/// valores fora da lista. Portanto provider/status ficam `String` (um enum
/// estrito quebraria o decode num valor novo).

public struct AtlasAiSession: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let threadId: String
    public let provider: String?
    public let model: String?
    public let title: String?
    public let status: String
    public let startedAt: String?
    public let endedAt: String?
    public let metadata: JSONObject?
    public let createdAt: String
    public let updatedAt: String
}

public struct AtlasAiMessage: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let threadId: String
    public let traceId: String?
    public let position: Int
    public let role: String
    public let status: String
    public let content: String
    public let provider: String?
    public let model: String?
    public let agentSlug: String?
    public let tokenEstimate: Int?
    public let occurredAt: String?
    public let metadata: JSONObject?
    public let createdAt: String
    public let updatedAt: String
}

public struct AtlasAiThread: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let summary: String?
    public let status: String
    public let surface: String
    public let workspace: String?
    public let sourceType: String?
    public let sourceId: String?
    public let lastTraceId: String?
    public let lastProvider: String?
    public let messageCount: Int
    public let lastMessageAt: String?
    public let metadata: JSONObject?
    // Relations pesadas (light=true as omite). Porta o resto do grafo depois.
    public let messages: [AtlasAiMessage]?
    public let activeSession: AtlasAiSession?
    public let createdAt: String
    public let updatedAt: String
}

