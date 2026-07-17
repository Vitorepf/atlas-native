import Foundation
import AtlasCore

/// Phase spoken — peel de AutonomosAreaPicker+A11y.

enum AutonomosAreaPickerA11yPhase {
    static func spokenPhase(_ phase: AtlasAutonomosLoopPhase) -> String {
        switch phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }
}
