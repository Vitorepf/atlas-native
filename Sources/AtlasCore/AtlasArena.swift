import Foundation

public struct AtlasArenaCapabilities: Sendable, Equatable, Decodable {
    public static let schemaVersion = "atlas.arena.capabilities.v2"

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

/// Delta com-vs-sem-Atlas com IC de Newcombe. `significant` = o IC 95% não cruza zero.
public struct AtlasArenaCapabilityDelta: Codable, Sendable, Equatable {
    public let value: Double
    public let ciLow: Double
    public let ciHigh: Double
    public let significant: Bool
}

public struct AtlasArenaCapability: Codable, Sendable, Equatable, Identifiable {
    public var id: String { capability }

    public let capability: String
    public let labelPt: String
    public let score: Double?
    public let withAtlas: Double?
    /// IC 95% de Wilson [baixo, alto] de cada braço — a verdade contínua da confiança.
    public let baselineCi: [Double]?
    public let withAtlasCi: [Double]?
    /// N por braço (soma das rodadas). O piso `minCasesForConfidence` separa medido de "poucos casos".
    public let baselineCases: Int?
    public let withAtlasCases: Int?
    public let delta: AtlasArenaCapabilityDelta?
    /// "measured" | "low" | "unmeasured" — nunca cravar número de baixa confiança como verdade.
    public let confidence: String?
    /// "binary" (pass@1, taxa de acerto) | "continuous" (média de score, ex. rougeL).
    /// Distingue 0.14-rougeL de 0.14-pass@1 — sem isso o número lê fora de escala.
    public let measurementType: String?
    public let suitesContributing: [String]
    public let casesTotal: Int?
    public let minCasesForConfidence: Int?

    public enum Confidence: String { case measured, low, unmeasured }

    /// Verdadeiro quando a nota é uma MÉDIA de score contínuo (não taxa binária).
    public var isContinuous: Bool { measurementType == "continuous" }

    /// Fail-open: servidor v1 antigo (sem o campo) vira `.low` — nunca finge medido.
    public var confidenceLevel: Confidence {
        guard let confidence, let level = Confidence(rawValue: confidence) else {
            return (score == nil && withAtlas == nil) ? .unmeasured : .low
        }
        return level
    }
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
