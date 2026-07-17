import Foundation

// Continuity viva da thread: handoff entre superfícies (mobile/desktop/terminal)
// e feedback de interação. SessionState/Compaction/ProviderHandoff/ContextSnapshot
// e as rotas admin create/state/compact/switch/snapshots foram podadas em F0.3
// — 0 consumidores de produto. AtlasAiThread / AtlasAiTrace vivem em
// AtlasAiModels.swift.

/// Recibo mínimo para abrir a mesma thread/sessão em outra superfície. Não
/// contém brief, prompt, metadata, provider ou conteúdo da conversa.
public struct AtlasAiSurfaceHandoff: Codable, Sendable, Identifiable {
    public let schemaVersion: String
    public let handoffId: String
    public let threadId: String
    public let sessionId: String
    public let fromSurface: String
    public let toSurface: String
    public let status: String
    public let createdAt: String?

    public var id: String { handoffId }
}

public struct AiSurfaceHandoffResponse: Codable, Sendable {
    public let handoff: AtlasAiSurfaceHandoff
}

public enum AtlasAiSurfaceDestination: String, Codable, Sendable, CaseIterable {
    case mobile = "atlas_mobile"
    case desktop = "atlas_desktop"
    case terminal = "atlas_terminal"
}

public struct HandoffAiThreadSurfaceInput: Encodable, Sendable {
    public var toSurface: AtlasAiSurfaceDestination

    public init(toSurface: AtlasAiSurfaceDestination) {
        self.toSurface = toSurface
    }
}

public struct FeedbackAiInteractionInput: Encodable, Sendable {
    public var feedbackScore: Double?
    public var feedbackAction: String?
    public var feedbackComment: String?

    public init(
        feedbackScore: Double? = nil,
        feedbackAction: String? = nil,
        feedbackComment: String? = nil
    ) {
        self.feedbackScore = feedbackScore
        self.feedbackAction = feedbackAction
        self.feedbackComment = feedbackComment
    }
}

public extension AtlasClient {
    /// Cria um recibo provider-safe para outra superfície abrir a mesma thread
    /// e sessão canônicas; não cria conversa, sessão ou provider novo.
    func handoffAiThreadSurface(_ id: String, input: HandoffAiThreadSurfaceInput) async throws -> AiSurfaceHandoffResponse {
        return try await post(AtlasRoute.aiThreadHandoffSurface(id), body: input)
    }

    /// `feedbackAiInteraction` — score/ação/comentário do operador no turno.
    func feedbackAiInteraction(_ id: String, feedback: FeedbackAiInteractionInput) async throws -> AiTraceResponse {
        return try await post(AtlasRoute.aiInteractionFeedback(id), body: feedback)
    }
}
