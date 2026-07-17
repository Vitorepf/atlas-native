import Foundation

/// Itens de risco e decisão pendente — peel de AtlasAutonomosDigest.

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
