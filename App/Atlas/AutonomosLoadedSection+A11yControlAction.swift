import Foundation
import AtlasCore

/// Action spoken — peel de AutonomosLoadedSection+A11yControl.

enum AutonomosLoadedSectionA11yControlAction {
    static func spokenAction(_ action: AtlasAutonomosRunAction) -> String {
        switch action {
        case .pause: return "pausar"
        case .resume: return "retomar"
        case .kill: return "encerrar"
        case .clearKill: return "limpar encerramento"
        }
    }
}
