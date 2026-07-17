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

public enum AtlasInteractionSteerScope: String, Codable, Sendable, Equatable, CaseIterable {
    case currentStep = "current_step"
    case replan
}

public struct AtlasInteractionSteerInput: Encodable, Sendable, Equatable {
    public let instruction: String
    public let scope: AtlasInteractionSteerScope

    public init(instruction: String, scope: AtlasInteractionSteerScope) {
        self.instruction = instruction.trimmingCharacters(in: .whitespacesAndNewlines)
        self.scope = scope
    }
}

public enum AtlasInteractionSteerStatus: String, Codable, Sendable, Equatable {
    case accepted
    case rejected
}

public enum AtlasInteractionSteerEvent: String, Codable, Sendable, Equatable {
    case accepted = "steering_accepted"
    case rejected = "steering_rejected"
}

public enum AtlasInteractionSteerDeliveryStatus: String, Codable, Sendable, Equatable {
    case queuedForNextSafeCheckpoint = "queued_for_next_safe_checkpoint"
    case notQueued = "not_queued"
}

public struct AtlasInteractionSteerDelivery: Codable, Sendable, Equatable {
    public let status: AtlasInteractionSteerDeliveryStatus
}

public enum AtlasInteractionSteerRejectionReason: String, Codable, Sendable, Equatable, CaseIterable {
    case instructionRequired = "instruction_required"
    case invalidScope = "invalid_scope"
    case traceWithoutThread = "trace_without_thread"
    case noActiveJob = "no_active_job"
}

public struct AtlasInteractionSteerResponse: Decodable, Sendable, Equatable {
    public static let schemaVersion = "atlas.ai.interaction_steer.v1"

    public let schemaVersion: String
    public let status: AtlasInteractionSteerStatus
    public let event: AtlasInteractionSteerEvent
    public let traceId: String?
    public let delivery: AtlasInteractionSteerDelivery?
    public let reason: AtlasInteractionSteerRejectionReason?

    enum CodingKeys: String, CodingKey {
        case schemaVersion, status, event, traceId, delivery, reason
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.requireSchema(
            Self.schemaVersion,
            forKey: .schemaVersion,
            message: "Unsupported interaction steer schema."
        )
        let status = try values.decode(AtlasInteractionSteerStatus.self, forKey: .status)
        let event = try values.decode(AtlasInteractionSteerEvent.self, forKey: .event)
        let traceId = try values.decodeIfPresent(String.self, forKey: .traceId)
        let delivery = try values.decodeIfPresent(AtlasInteractionSteerDelivery.self, forKey: .delivery)
        let reason = try values.decodeIfPresent(AtlasInteractionSteerRejectionReason.self, forKey: .reason)

        switch status {
        case .accepted:
            guard event == .accepted,
                  delivery?.status == .queuedForNextSafeCheckpoint,
                  reason == nil else {
                throw DecodingError.dataCorruptedError(
                    forKey: .status,
                    in: values,
                    debugDescription: "Accepted steer response must be queued for next safe checkpoint."
                )
            }
        case .rejected:
            guard event == .rejected, reason != nil else {
                throw DecodingError.dataCorruptedError(
                    forKey: .reason,
                    in: values,
                    debugDescription: "Rejected steer response must include a public reason."
                )
            }
        }

        self.schemaVersion = schemaVersion
        self.status = status
        self.event = event
        self.traceId = traceId
        self.delivery = delivery
        self.reason = reason
    }

    public var isAccepted: Bool { status == .accepted }
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
