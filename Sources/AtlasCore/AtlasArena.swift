import Foundation

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

/// Catálogo de motores rodáveis (B6) — enabled, nunca harness-only.
public struct AtlasArenaEngines: Sendable, Equatable, Decodable {
    public static let schemaVersion = "atlas.arena.engines.v1"

    public let schemaVersion: String
    public let generatedAt: String?
    public let engines: [AtlasArenaEngineOption]

    enum CodingKeys: String, CodingKey {
        case schemaVersion, generatedAt, engines
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Arena engines schema.")
        generatedAt = try values.decodeIfPresent(String.self, forKey: .generatedAt)
        engines = try values.decodeIfPresent([AtlasArenaEngineOption].self, forKey: .engines) ?? []
    }
}

public struct AtlasArenaEngineOption: Codable, Sendable, Equatable, Identifiable {
    public var id: String { engine }

    public let engine: String
    public let accessType: String?
    public let local: Bool?
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
    /// Identidade pública estável da medição que agrupa suítes, motores e braços.
    public let measurementIdPublic: String?
    public let suite: String
    public let engine: String?
    public let arm: AtlasArenaRunArm?
    public let status: AtlasArenaRunStatus
    public let casesDone: Int?
    public let casesTotal: Int?
    public let startedAt: String?
    public let queuedAt: String?
    public let completedAt: String?
    public let stopRequestedAt: String?
    public let stoppedAt: String?
    /// Código público allowlisted; motivo interno e stdout nunca chegam à UI.
    public let failureCode: String?
    public let terminalReceiptHash: String?
    /// Ação declarada pelo servidor; a casca nunca infere Parar pelo status.
    public let canStop: Bool?
    /// De onde o run foi disparado (`iphone|ipad|mac|cli`) — opcional
    /// fail-open: servidor antigo sem o campo não derruba o AGORA.
    public let origin: String?

    public var engineDisplayName: String {
        guard let engine, !engine.isEmpty else { return "motor desconhecido" }
        return engine
    }

    public var progressText: String {
        guard let casesDone, let casesTotal, casesTotal > 0 else { return status.displayPT }
        return "\(casesDone)/\(casesTotal)"
    }
}
