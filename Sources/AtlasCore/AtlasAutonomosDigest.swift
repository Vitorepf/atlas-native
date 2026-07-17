import Foundation

/// Digest agendado do Autônomos: janela, contagens e itens provider-safe
/// publicados pelo servidor para a casca.
public struct AtlasAutonomosDigestResponse: Decodable, Sendable, Equatable {
    public static let schemaVersion = "atlas.autonomos.digest.v1"

    public let schemaVersion: String
    public let readOnly: Bool
    public let providerSafe: Bool
    public let nextDigestAt: String?
    public let schedule: AtlasAutonomosDigestSchedule
    public let last: AtlasAutonomosDigestLast

    enum CodingKeys: String, CodingKey {
        case schemaVersion, readOnly, providerSafe, nextDigestAt, schedule, last
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(
            Self.schemaVersion,
            forKey: .schemaVersion,
            message: "Unsupported Autonomos digest schema."
        )
        readOnly = try values.decode(Bool.self, forKey: .readOnly)
        providerSafe = try values.decode(Bool.self, forKey: .providerSafe)
        nextDigestAt = try values.decodeIfPresent(String.self, forKey: .nextDigestAt)
        schedule = try values.decode(AtlasAutonomosDigestSchedule.self, forKey: .schedule)
        last = try values.decode(AtlasAutonomosDigestLast.self, forKey: .last)
    }
}

public struct AtlasAutonomosDigestSchedule: Codable, Sendable, Equatable {
    public let available: Bool
    public let source: String?
    public let reason: String?
}

public struct AtlasAutonomosDigestLast: Codable, Sendable, Equatable {
    public let window: AtlasAutonomosDigestWindow
    public let counts: AtlasAutonomosDigestCounts
    public let delivered: [AtlasAutonomosDigestDelivered]
    public let risks: [AtlasAutonomosDigestRisk]
    public let pendingDecisions: [AtlasAutonomosDigestPendingDecision]
    public let sourceStatuses: JSONObject
}

public struct AtlasAutonomosDigestWindow: Codable, Sendable, Equatable {
    public let kind: String
    public let hours: Int
    public let startedAt: String
    public let endedAt: String
    public let timezone: String
    public let areas: [String]
    public let focus: String
}

public struct AtlasAutonomosDigestCounts: Codable, Sendable, Equatable {
    public let delivered: Int
    public let risks: Int
    public let pendingDecisions: Int
}

public struct AtlasAutonomosDigestDelivered: Codable, Sendable, Equatable, Identifiable {
    public let source: String
    public let areaId: String
    public let focus: String
    public let cycleIndex: Int
    public let cycleId: String
    public let outcome: String
    public let cycleFinalStatus: String
    public let mergePerformed: Bool
    public let mergeHash: String
    public let recordedAt: String

    public var id: String { "\(areaId):\(cycleIndex):\(cycleId)" }
}

public struct AtlasAutonomosDigestRisk: Codable, Sendable, Equatable, Identifiable {
    public let source: String
    public let areaId: String
    public let focus: String
    public let cycleIndex: Int?
    public let cycleId: String?
    public let findingId: String?
    public let title: String?
    public let severity: String
    public let reason: String?
    public let blockers: [String]?
    public let quarantined: Bool?
    public let route: String?
    public let routeReason: String?
    public let priorityScore: Int?
    public let evidenceRefs: [String]?
    public let recordedAt: String?

    public var id: String {
        if let findingId { return "\(areaId):finding:\(findingId)" }
        return "\(areaId):cycle:\(cycleIndex.map(String.init) ?? "none"):\(cycleId ?? "none")"
    }
}

public struct AtlasAutonomosDigestPendingDecision: Codable, Sendable, Equatable, Identifiable {
    public let source: String
    public let areaId: String
    public let focus: String
    public let findingId: String
    public let title: String
    public let severity: String
    public let route: String
    public let routeReason: String?
    public let priorityScore: Int
    public let operatorDecisionRequired: Bool

    public var id: String { "\(areaId):\(findingId)" }
}
