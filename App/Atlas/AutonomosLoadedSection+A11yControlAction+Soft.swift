import Foundation
import AtlasCore

/// Soft action spoken — peel de AutonomosLoadedSection+A11yControlAction.

enum AutonomosLoadedSectionA11yControlActionSoft {
    static func spokenAction(_ action: AtlasAutonomosRunAction) -> String? {
        switch action {
        case .pause: return "pausar"
        case .resume: return "retomar"
        default: return nil
        }
    }
}
