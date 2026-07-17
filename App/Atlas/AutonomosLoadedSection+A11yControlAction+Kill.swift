import Foundation
import AtlasCore

/// Kill spoken actions — peel de AutonomosLoadedSection+A11yControlAction.

enum AutonomosLoadedSectionA11yControlActionKill {
    static func spokenAction(_ action: AtlasAutonomosRunAction) -> String? {
        switch action {
        case .kill: return "encerrar"
        case .clearKill: return "limpar encerramento"
        default: return nil
        }
    }
}
