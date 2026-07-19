import Foundation

// Run arm/status DTOs — peel de AtlasArena (régua <110).

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
    case stopping
    case stopped
    case completed
    case failed
    case unknown(String)

    public var rawValue: String {
        switch self {
        case .queued: return "queued"
        case .running: return "running"
        case .stopping: return "stopping"
        case .stopped: return "stopped"
        case .completed: return "completed"
        case .failed: return "failed"
        case .unknown(let value): return value
        }
    }

    public var displayPT: String {
        switch self {
        case .queued: return "na fila, ainda não iniciado"
        case .running: return "em medição"
        case .stopping: return "parada solicitada"
        case .stopped: return "parada pelo operador"
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
        case "stopping", "stop_requested": self = .stopping
        case "stopped", "cancelled", "canceled": self = .stopped
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
