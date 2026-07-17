import Foundation

/// Start/enqueue + AtlasClient Arena methods — DTOs de leitura ficam em
/// `AtlasArena.swift`; mutação e transporte vivem aqui.
public enum AtlasArenaStartSuites: Sendable, Equatable {
    case all
    case selected([String])

    public var selectedValues: [String] {
        switch self {
        case .all: return ["all"]
        case .selected(let values): return values
        }
    }
}

extension AtlasArenaStartSuites: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self), string == "all" {
            self = .all
            return
        }
        self = .selected(try container.decode([String].self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .all:
            try container.encode("all")
        case .selected(let values):
            try container.encode(values)
        }
    }
}

public struct AtlasArenaStartInput: Codable, Sendable, Equatable {
    public let suites: AtlasArenaStartSuites
    public let engine: String
    public let arms: [AtlasArenaRunArm]
    public let operatorActor: String
    public let operatorReason: String

    public init(
        suites: AtlasArenaStartSuites,
        engine: String,
        arms: [AtlasArenaRunArm] = [.baseline, .withAtlas],
        operatorActor: String,
        operatorReason: String
    ) {
        let trimmedSuites: AtlasArenaStartSuites
        switch suites {
        case .all:
            trimmedSuites = .all
        case .selected(let values):
            trimmedSuites = .selected(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty })
        }
        self.suites = trimmedSuites
        self.engine = engine.trimmingCharacters(in: .whitespacesAndNewlines)
        self.arms = arms
        self.operatorActor = operatorActor.trimmingCharacters(in: .whitespacesAndNewlines)
        self.operatorReason = operatorReason.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isLocallyValidForSubmission: Bool {
        !operatorActor.isEmpty && !operatorReason.isEmpty && !engine.isEmpty && !suites.selectedValues.isEmpty && !arms.isEmpty
    }
}

public struct AtlasArenaStartReceipt: Sendable, Equatable, Decodable {
    public static let schemaVersion = "atlas.arena.start_receipt.v1"

    public let schemaVersion: String
    public let status: String
    public let receiptHash: String
    public let runsPlanned: Int
    public let started: Bool
    public let workerImplemented: Bool
    public let providerInvoked: Bool?
    public let note: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion, status, receiptHash, runsPlanned, started, workerImplemented, providerInvoked, note
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Arena start receipt schema.")
        status = try values.decode(String.self, forKey: .status)
        receiptHash = try values.decode(String.self, forKey: .receiptHash)
        runsPlanned = try values.decode(Int.self, forKey: .runsPlanned)
        started = try values.decodeIfPresent(Bool.self, forKey: .started) ?? false
        workerImplemented = try values.decodeIfPresent(Bool.self, forKey: .workerImplemented) ?? false
        providerInvoked = try values.decodeIfPresent(Bool.self, forKey: .providerInvoked)
        note = try values.decodeIfPresent(String.self, forKey: .note)
    }

    public var isEnqueued: Bool { status == "enqueued" && !started }
}

public enum AtlasArenaClientError: Error, Sendable, Equatable {
    case invalidStartInput
}

public extension AtlasClient {
    func getArenaComposite() async throws -> AtlasArenaComposite {
        try await get(AtlasRoute.arenaComposite)
    }

    func getArenaScoreboard() async throws -> AtlasArenaScoreboard {
        try await get(AtlasRoute.arenaScoreboard)
    }

    func getArenaCapabilities(engine: String) async throws -> AtlasArenaCapabilities {
        try await get(AtlasRoute.arenaCapabilities(engine: engine))
    }

    func getArenaLiveRuns() async throws -> AtlasArenaLiveRuns {
        try await get(AtlasRoute.arenaLiveRuns)
    }

    func startArenaRuns(input: AtlasArenaStartInput) async throws -> AtlasArenaStartReceipt {
        guard input.isLocallyValidForSubmission else { throw AtlasArenaClientError.invalidStartInput }
        return try await post(AtlasRoute.arenaRuns, body: input, timeout: 30)
    }
}
