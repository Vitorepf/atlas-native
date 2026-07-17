import Foundation
import AtlasCore

/// Placement / sistemas / fase — peel de AutonomosAreaDetailSection+A11y.
/// Placement spoken → AutonomosAreaDetailSection+A11yPlacementSpoken.swift

extension AutonomosAreaDetailA11y {
    static func spokenOwnedSystems(_ systems: [String]) -> String {
        "sistemas sob responsabilidade, \(systems.joined(separator: ", "))"
    }

    static func spokenMetric(label: String, value: Int?) -> String {
        guard let value else { return "\(label) não publicado" }
        return "\(value) \(label)"
    }

    static func spokenPhase(_ phase: AtlasAutonomosLoopPhase) -> String {
        switch phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }
}
