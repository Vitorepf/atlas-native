import SwiftUI
import AtlasCore

// Phase helpers — peel de AutonomosAreaPicker+Row.

extension AutonomosAreaPicker {
    func areaStateLabel(_ area: AtlasAutonomosArea) -> String {
        switch area.loopStatus.phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }

    func areaStateColor(_ area: AtlasAutonomosArea) -> Color {
        switch area.loopStatus.phase {
        case .terminated: return AtlasTheme.domOperacional
        case .paused: return AtlasTheme.accent
        case .running: return AtlasTheme.domAutonomos
        case .idle: return AtlasTheme.textTertiary
        }
    }
}
