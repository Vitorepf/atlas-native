import Foundation

/// Lifecycle público do turno/job. Wire-tolerante: valor desconhecido não quebra
/// decode (fail-open no bag), mas nunca é tratado como terminal nem suspensão.
public enum AtlasTurnStatus: Sendable, Equatable {
    case queued
    case processing
    case awaitingUserChoice
    case awaitingExternal
    case succeeded
    case failed
    case cancelled
    case unknown(String)

    public init(rawValue: String) {
        switch rawValue.lowercased() {
        case "queued": self = .queued
        case "processing": self = .processing
        case "awaiting_user_choice": self = .awaitingUserChoice
        case "awaiting_external": self = .awaitingExternal
        case "succeeded": self = .succeeded
        case "failed": self = .failed
        case "cancelled": self = .cancelled
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .queued: return "queued"
        case .processing: return "processing"
        case .awaitingUserChoice: return "awaiting_user_choice"
        case .awaitingExternal: return "awaiting_external"
        case .succeeded: return "succeeded"
        case .failed: return "failed"
        case .cancelled: return "cancelled"
        case .unknown(let value): return value
        }
    }

    public var isTerminal: Bool {
        switch self {
        case .succeeded, .failed, .cancelled: return true
        default: return false
        }
    }

    public var isSuspension: Bool {
        switch self {
        case .awaitingUserChoice, .awaitingExternal: return true
        default: return false
        }
    }

    /// Job ainda elegível a cancel remoto (fila/processamento).
    public var isActiveWork: Bool {
        switch self {
        case .queued, .processing: return true
        default: return false
        }
    }
}

public extension AtlasAiTrace {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: status) }
}

public extension AtlasAiJob {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: status) }
}

public extension AtlasAiStreamDone {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: status) }
}

/// Golden: mapeamento wire→enum e a lei de que `.unknown` nunca é terminal.
public func runTurnStatusChecks(_ check: (String, Bool) -> Void) {
    check("queued", AtlasTurnStatus(rawValue: "queued") == .queued)
    check("processing", AtlasTurnStatus(rawValue: "processing") == .processing)
    check("awaiting_user_choice", AtlasTurnStatus(rawValue: "awaiting_user_choice") == .awaitingUserChoice)
    check("awaiting_external", AtlasTurnStatus(rawValue: "awaiting_external") == .awaitingExternal)
    check("succeeded terminal", AtlasTurnStatus(rawValue: "succeeded").isTerminal)
    check("failed terminal", AtlasTurnStatus(rawValue: "FAILED").isTerminal)
    check("cancelled terminal", AtlasTurnStatus(rawValue: "cancelled").isTerminal)
    check("suspensão awaiting*", AtlasTurnStatus(rawValue: "awaiting_user_choice").isSuspension
          && AtlasTurnStatus(rawValue: "awaiting_external").isSuspension)
    check("activeWork só fila/processamento",
          AtlasTurnStatus(rawValue: "queued").isActiveWork
          && AtlasTurnStatus(rawValue: "processing").isActiveWork
          && !AtlasTurnStatus(rawValue: "succeeded").isActiveWork)
    let unknown = AtlasTurnStatus(rawValue: "provider_weird_status")
    check("unknown nunca terminal", !unknown.isTerminal && !unknown.isSuspension && !unknown.isActiveWork)
    if case .unknown(let raw) = unknown {
        check("unknown preserva raw", raw == "provider_weird_status")
    } else {
        check("unknown preserva raw", false)
    }
}
