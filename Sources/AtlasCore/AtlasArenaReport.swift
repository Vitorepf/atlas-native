import Foundation

/// Relatório editorial provider-safe já publicado pelo servidor da Arena.
///
/// Ele alimenta Resultados e Alertas sem expor ids internos, prompts, paths,
/// logs ou stdout das suítes. `claimAllowed` é obrigatório e falha fechado.
public struct AtlasArenaReport: Sendable, Equatable, Decodable {
    public static let schemaVersion = "atlas.arena.report.v1"

    public let schemaVersion: String
    public let builtAt: String?
    public let claimAllowed: Bool
    public let claimBlockers: [String]
    public let narrative: String?
    public let primaryEngine: String?
    public let suitesOk: Int
    public let suitesFailed: Int
    public let suitesBlocked: Int
    public let suitesMissingData: Int
    public let suites: [AtlasArenaReportSuite]
    public let engines: [AtlasArenaReportEngine]

    public var suitesNotRun: Int {
        suites.count { $0.status == .notRun }
    }

    public var attentionSuites: [AtlasArenaReportSuite] {
        suites.filter { $0.status.requiresAttention }
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion, builtAt, claimAllowed, claimBlockers, narrative
        case primaryEngine, suitesOk, suitesFailed, suitesBlocked, suitesMissingData
        case suites, engines
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(
            Self.schemaVersion,
            forKey: .schemaVersion,
            message: "Unsupported Atlas Arena report schema."
        )
        builtAt = try values.decodeIfPresent(String.self, forKey: .builtAt)
        claimAllowed = try values.decode(Bool.self, forKey: .claimAllowed)
        claimBlockers = try values.decodeIfPresent([String].self, forKey: .claimBlockers) ?? []
        narrative = try values.decodeIfPresent(String.self, forKey: .narrative)
        primaryEngine = try values.decodeIfPresent(String.self, forKey: .primaryEngine)
        suitesOk = try values.decode(Int.self, forKey: .suitesOk)
        suitesFailed = try values.decode(Int.self, forKey: .suitesFailed)
        suitesBlocked = try values.decode(Int.self, forKey: .suitesBlocked)
        suitesMissingData = try values.decode(Int.self, forKey: .suitesMissingData)
        suites = try values.decodeIfPresent([AtlasArenaReportSuite].self, forKey: .suites) ?? []
        engines = try values.decodeIfPresent([AtlasArenaReportEngine].self, forKey: .engines) ?? []
    }
}

public struct AtlasArenaReportSuite: Codable, Sendable, Equatable, Identifiable {
    public var id: String { suite }

    public let suite: String
    public let status: AtlasArenaReportSuiteStatus
    public let successRate: Double?
    public let intelligenceRate: Double?
    public let medianWallMs: Int?
    public let costPerTask: Double?
    public let envFailureRate: Double?
    public let pipelineValid: Bool
}

public enum AtlasArenaReportSuiteStatus: Sendable, Equatable, Hashable {
    case ok
    case failed
    case blocked
    case missingData
    case notRun
    case unknown(String)

    public var rawValue: String {
        switch self {
        case .ok: return "ok"
        case .failed: return "failed"
        case .blocked: return "blocked"
        case .missingData: return "missing_data"
        case .notRun: return "not_run"
        case .unknown(let value): return value
        }
    }

    public var displayPT: String {
        switch self {
        case .ok: return "medida"
        case .failed: return "falhou"
        case .blocked: return "bloqueada"
        case .missingData: return "dados incompletos"
        case .notRun: return "ainda não medida"
        case .unknown: return "estado não reconhecido"
        }
    }

    public var requiresAttention: Bool {
        switch self {
        case .failed, .blocked, .missingData, .unknown: return true
        case .ok, .notRun: return false
        }
    }
}

extension AtlasArenaReportSuiteStatus: Codable {
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "ok": self = .ok
        case "failed": self = .failed
        case "blocked": self = .blocked
        case "missing_data": self = .missingData
        case "not_run": self = .notRun
        default: self = .unknown(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct AtlasArenaReportEngine: Codable, Sendable, Equatable, Identifiable {
    public var id: String { engine }

    public let engine: String
    public let runtimesMeasured: [String]
    public let narrative: String?
    public let strengths: [AtlasArenaReportEdge]
    public let weaknesses: [AtlasArenaReportEdge]
}

public struct AtlasArenaReportEdge: Codable, Sendable, Equatable, Identifiable {
    public var id: String { "\(suite):\(category)" }

    public let suite: String
    public let category: String
    public let successRate: Double?
}
