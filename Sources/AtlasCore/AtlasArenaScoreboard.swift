import Foundation

public struct AtlasArenaScoreboard: Sendable, Equatable, Decodable {
    public static let schemaVersion = "atlas.arena.scoreboard.v1"

    public let schemaVersion: String
    public let generatedAt: String?
    public let suites: [AtlasArenaSuite]

    enum CodingKeys: String, CodingKey {
        case schemaVersion, generatedAt, suites
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Arena scoreboard schema.")
        generatedAt = try values.decodeIfPresent(String.self, forKey: .generatedAt)
        suites = try values.decodeIfPresent([AtlasArenaSuite].self, forKey: .suites) ?? []
    }
}

public struct AtlasArenaSuite: Codable, Sendable, Equatable, Identifiable {
    public var id: String { suite }

    public let suite: String
    public let runsTotal: Int
    public let lastRunAt: String?
    public let adapterInstalled: Bool
    public let engines: [AtlasArenaSuiteEngine]

    public var isMeasured: Bool { runsTotal > 0 || engines.contains { $0.score != nil || $0.withAtlasScore != nil } }
    public var hasRegression: Bool { engines.contains(where: \.regressed) }
}

public struct AtlasArenaSuiteEngine: Codable, Sendable, Equatable, Identifiable {
    public var id: String { engine }

    public let engine: String
    public let score: Double?
    public let previousScore: Double?
    public let delta: Double?
    public let withAtlasScore: Double?
    public let withoutAtlasScore: Double?
    public let atlasMultiplier: Double?
    public let casesPassed: Int?
    public let casesFailed: Int?
    public let casesTotal: Int?
    public let durationAvgMs: Int?
    public let regressed: Bool
    public let history: [AtlasArenaSuitePoint]
}

public struct AtlasArenaSuitePoint: Codable, Sendable, Equatable, Identifiable {
    public var id: String { "\(roundAt):\(arm?.rawValue ?? "unknown")" }

    public let roundAt: String
    public let score: Double?
    public let arm: AtlasArenaRunArm?
}
