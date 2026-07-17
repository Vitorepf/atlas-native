import Foundation

public struct AtlasArenaComposite: Sendable, Equatable, Decodable {
    public static let schemaVersion = "atlas.arena.composite.v1"

    public let schemaVersion: String
    public let generatedAt: String?
    public let suitesTotal: Int
    public let suitesMeasured: Int
    public let weightsPublic: [String: Double]
    public let engines: [AtlasArenaCompositeEngine]

    enum CodingKeys: String, CodingKey {
        case schemaVersion, generatedAt, suitesTotal, suitesMeasured, weightsPublic, engines
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Arena composite schema.")
        generatedAt = try values.decodeIfPresent(String.self, forKey: .generatedAt)
        suitesTotal = try values.decode(Int.self, forKey: .suitesTotal)
        suitesMeasured = try values.decode(Int.self, forKey: .suitesMeasured)
        weightsPublic = try values.decodeIfPresent([String: Double].self, forKey: .weightsPublic) ?? [:]
        engines = try values.decodeIfPresent([AtlasArenaCompositeEngine].self, forKey: .engines) ?? []
    }
}

public struct AtlasArenaCompositeEngine: Codable, Sendable, Equatable, Identifiable {
    public var id: String { engine }

    public let engine: String
    public let composite: Double?
    public let previous: Double?
    public let delta: Double?
    public let withAtlasComposite: Double?
    public let withoutAtlasComposite: Double?
    public let atlasMultiplier: Double?
    public let coverage: Double
    public let history: [AtlasArenaCompositePoint]

    public var isPartialCoverage: Bool { coverage < 0.999 }
    public var regressed: Bool { (delta ?? 0) < 0 }
}

public struct AtlasArenaCompositePoint: Codable, Sendable, Equatable, Identifiable {
    public var id: String { roundAt }

    public let roundAt: String
    public let composite: Double?
    public let withAtlas: Double?
    public let withoutAtlas: Double?
}

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

public struct AtlasArenaCapabilities: Sendable, Equatable, Decodable {
    public static let schemaVersion = "atlas.arena.capabilities.v1"

    public let schemaVersion: String
    public let mappingVersion: String
    public let engine: String?
    public let capabilities: [AtlasArenaCapability]

    enum CodingKeys: String, CodingKey {
        case schemaVersion, mappingVersion, engine, capabilities
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Arena capabilities schema.")
        mappingVersion = try values.decode(String.self, forKey: .mappingVersion)
        engine = try values.decodeIfPresent(String.self, forKey: .engine)
        capabilities = try values.decodeIfPresent([AtlasArenaCapability].self, forKey: .capabilities) ?? []
    }
}

public struct AtlasArenaCapability: Codable, Sendable, Equatable, Identifiable {
    public var id: String { capability }

    public let capability: String
    public let labelPt: String
    public let score: Double?
    public let withAtlas: Double?
    public let suitesContributing: [String]
    public let casesTotal: Int?
}

public struct AtlasArenaLiveRuns: Sendable, Equatable, Decodable {
    public static let schemaVersion = "atlas.arena.runs_live.v1"

    public let schemaVersion: String
    public let generatedAt: String?
    public let runs: [AtlasArenaLiveRun]

    enum CodingKeys: String, CodingKey {
        case schemaVersion, generatedAt, runs
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Arena live-runs schema.")
        generatedAt = try values.decodeIfPresent(String.self, forKey: .generatedAt)
        runs = try values.decodeIfPresent([AtlasArenaLiveRun].self, forKey: .runs) ?? []
    }
}

public struct AtlasArenaLiveRun: Codable, Sendable, Equatable, Identifiable {
    public var id: String { runIdPublic }

    public let runIdPublic: String
    public let suite: String
    public let engine: String?
    public let arm: AtlasArenaRunArm?
    public let status: AtlasArenaRunStatus
    public let casesDone: Int?
    public let casesTotal: Int?
    public let startedAt: String?
    public let queuedAt: String?

    public var engineDisplayName: String {
        guard let engine, !engine.isEmpty else { return "motor desconhecido" }
        return engine
    }

    public var progressText: String {
        guard let casesDone, let casesTotal, casesTotal > 0 else { return status.displayPT }
        return "\(casesDone)/\(casesTotal)"
    }
}

public enum AtlasArenaRunArm: String, Codable, Sendable, Equatable, CaseIterable, Identifiable {
    case baseline
    case withAtlas = "with_atlas"

    public var id: String { rawValue }

    public var labelPT: String {
        switch self {
        case .baseline: return "sem Atlas"
        case .withAtlas: return "com Atlas"
        }
    }
}

public enum AtlasArenaRunStatus: Sendable, Equatable, Hashable {
    case queued
    case running
    case completed
    case failed
    case unknown(String)

    public var rawValue: String {
        switch self {
        case .queued: return "queued"
        case .running: return "running"
        case .completed: return "completed"
        case .failed: return "failed"
        case .unknown(let value): return value
        }
    }

    public var displayPT: String {
        switch self {
        case .queued: return "na fila, ainda não iniciado"
        case .running: return "em medição"
        case .completed: return "concluído"
        case .failed: return "falhou"
        case .unknown(let value): return value
        }
    }
}

extension AtlasArenaRunStatus: Codable {
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "queued": self = .queued
        case "running": self = .running
        case "completed", "done", "reported": self = .completed
        case "failed", "error": self = .failed
        default: self = .unknown(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
