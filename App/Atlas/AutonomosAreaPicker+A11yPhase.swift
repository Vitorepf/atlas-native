import Foundation
import AtlasCore

/// Phase spoken — peel de AutonomosAreaPicker+A11y.
/// Soft → AutonomosAreaPicker+A11yPhase+Soft.swift

enum AutonomosAreaPickerA11yPhase {
    static func spokenPhase(_ phase: AtlasAutonomosLoopPhase) -> String {
        AutonomosAreaPickerA11yPhaseSoft.spokenPhase(phase) ?? "encerrada"
    }
}
