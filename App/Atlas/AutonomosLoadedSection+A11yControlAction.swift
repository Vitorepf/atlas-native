import Foundation
import AtlasCore

/// Action spoken — peel de AutonomosLoadedSection+A11yControl.
/// Soft → AutonomosLoadedSection+A11yControlAction+Soft.swift
/// Kill → AutonomosLoadedSection+A11yControlAction+Kill.swift

enum AutonomosLoadedSectionA11yControlAction {
    static func spokenAction(_ action: AtlasAutonomosRunAction) -> String {
        AutonomosLoadedSectionA11yControlActionSoft.spokenAction(action)
            ?? AutonomosLoadedSectionA11yControlActionKill.spokenAction(action)
            ?? "pausar"
    }
}
