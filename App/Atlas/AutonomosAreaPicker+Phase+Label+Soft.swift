import SwiftUI
import AtlasCore

// Soft phase labels — peel de AutonomosAreaPicker+Phase+Label.

extension AutonomosAreaPicker {
    func areaStateLabelSoft(_ area: AtlasAutonomosArea) -> String? {
        switch area.loopStatus.phase {
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "em espera"
        default: return nil
        }
    }
}
