import Foundation
import AtlasCore

// Loop phase spoken — peel de AutonomosAreaDetailSection+A11yPlacement.
// Soft → AutonomosAreaDetailSection+A11yPhase+Soft.swift

extension AutonomosAreaDetailA11y {
    static func spokenPhase(_ phase: AtlasAutonomosLoopPhase) -> String {
        spokenPhaseSoft(phase) ?? "encerrada"
    }
}
