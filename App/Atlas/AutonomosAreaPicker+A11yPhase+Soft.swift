import Foundation
import AtlasCore

/// Soft phase spoken — peel de AutonomosAreaPicker+A11yPhase.

enum AutonomosAreaPickerA11yPhaseSoft {
    static func spokenPhase(_ phase: AtlasAutonomosLoopPhase) -> String? {
        switch phase {
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        default: return nil
        }
    }
}
