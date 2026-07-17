import SwiftUI
import AtlasCore

// Soft phase colors — peel de AutonomosAreaPicker+Phase+Color.

extension AutonomosAreaPicker {
    func areaStateColorSoft(_ area: AtlasAutonomosArea) -> Color? {
        switch area.loopStatus.phase {
        case .paused: return AtlasTheme.accent
        case .running: return AtlasTheme.domAutonomos
        case .idle: return AtlasTheme.textTertiary
        default: return nil
        }
    }
}
