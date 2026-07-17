import Foundation
import AtlasCore

// Soft loop phase spoken — peel de AutonomosAreaDetailSection+A11yPhase.

extension AutonomosAreaDetailA11y {
    static func spokenPhaseSoft(_ phase: AtlasAutonomosLoopPhase) -> String? {
        switch phase {
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        default: return nil
        }
    }
}
