import Foundation

// Steer interaction DTOs — peel de AtlasAiThreadsExtra (régua anti-inchaço).

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
