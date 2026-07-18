import Foundation

/// Start/enqueue DTOs — peel de `AtlasClient+Arena.swift` (régua ~100).
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
    /// De onde o start partiu (`iphone|ipad|mac|cli`) — opcional; servidor
    /// projeta em runs_live para o AGORA mostrar a origem (goal 2).
    public let origin: String?

    public init(
        suites: AtlasArenaStartSuites,
        engine: String,
        arms: [AtlasArenaRunArm] = [.baseline, .withAtlas],
        operatorActor: String,
        operatorReason: String,
        origin: String? = nil
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
        let trimmedOrigin = origin?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.origin = (trimmedOrigin?.isEmpty ?? true) ? nil : trimmedOrigin
    }

    public var isLocallyValidForSubmission: Bool {
        !operatorActor.isEmpty && !operatorReason.isEmpty && !engine.isEmpty && !suites.selectedValues.isEmpty && !arms.isEmpty
    }
}
