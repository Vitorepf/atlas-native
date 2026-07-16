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
        let seg = id.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? id
        return try await post("/ai/threads/\(seg)/handoff-surface", body: input)
    }

    /// `feedbackAiInteraction` — score/ação/comentário do operador no turno.
    func feedbackAiInteraction(_ id: String, feedback: FeedbackAiInteractionInput) async throws -> AiTraceResponse {
        let seg = id.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? id
        return try await post("/ai/interactions/\(seg)/feedback", body: feedback)
    }
}

// MARK: - Golden checks

/// Prova o recibo de surface-handoff (snake→camel + encode do destino fechado).
public func runThreadsExtraChecks(_ check: (String, Bool) -> Void) {
    let dec = JSONDecoder()
    dec.keyDecodingStrategy = atlasSnakeKeyDecoding

    let surfaceHandoffJSON = """
    {
      "handoff": {
        "schema_version": "atlas.ai.surface_handoff.v1",
        "handoff_id": "surface_1",
        "thread_id": "th_42",
        "session_id": "session_7",
        "from_surface": "atlas_mobile",
        "to_surface": "atlas_terminal",
        "status": "ready",
        "created_at": "2026-07-14T00:00:00Z"
      }
    }
    """
    if let receipt = try? dec.decode(AiSurfaceHandoffResponse.self, from: Data(surfaceHandoffJSON.utf8)) {
        check("surface handoff preserva thread e sessão canônicas", receipt.handoff.threadId == "th_42" && receipt.handoff.sessionId == "session_7")
        check("surface handoff só projeta superfícies e status público", receipt.handoff.fromSurface == "atlas_mobile" && receipt.handoff.toSurface == "atlas_terminal" && receipt.handoff.status == "ready")
    } else {
        check("surface handoff decodes", false)
    }

    let handoffEncoder = JSONEncoder()
    handoffEncoder.keyEncodingStrategy = .convertToSnakeCase
    if let data = try? handoffEncoder.encode(HandoffAiThreadSurfaceInput(toSurface: .terminal)),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
        check("surface handoff só codifica o destino permitido", json == ["to_surface": "atlas_terminal"])
    } else {
        check("surface handoff input encodes", false)
    }
}
