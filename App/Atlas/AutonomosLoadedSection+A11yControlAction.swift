import Foundation
import AtlasCore

/// Action spoken — peel de AutonomosLoadedSection+A11yControl.
/// Soft → AutonomosLoadedSection+A11yControlAction+Soft.swift

enum AutonomosLoadedSectionA11yControlAction {
    static func spokenAction(_ action: AtlasAutonomosRunAction) -> String {
        if let soft = AutonomosLoadedSectionA11yControlActionSoft.spokenAction(action) {
            return soft
        }
        switch action {
        case .kill: return "encerrar"
        case .clearKill: return "limpar encerramento"
        default: return "pausar"
        }
    }
}
