import Foundation
import AtlasCore

// Loop phase spoken — peel de AutonomosAreaDetailSection+A11yPlacement.

extension AutonomosAreaDetailA11y {
    static func spokenPhase(_ phase: AtlasAutonomosLoopPhase) -> String {
        switch phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }
}
