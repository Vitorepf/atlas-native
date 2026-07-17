import SwiftUI
import AtlasCore

// Phase label — peel de AutonomosAreaPicker+Phase.

extension AutonomosAreaPicker {
    func areaStateLabel(_ area: AtlasAutonomosArea) -> String {
        switch area.loopStatus.phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }
}
