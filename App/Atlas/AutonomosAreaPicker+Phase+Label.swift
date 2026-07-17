import SwiftUI
import AtlasCore

// Phase label — peel de AutonomosAreaPicker+Phase.
// Soft → AutonomosAreaPicker+Phase+Label+Soft.swift

extension AutonomosAreaPicker {
    func areaStateLabel(_ area: AtlasAutonomosArea) -> String {
        areaStateLabelSoft(area) ?? "encerrada"
    }
}
