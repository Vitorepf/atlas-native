import SwiftUI
import AtlasCore

// Phase color — peel de AutonomosAreaPicker+Phase.
// Soft → AutonomosAreaPicker+Phase+Color+Soft.swift

extension AutonomosAreaPicker {
    func areaStateColor(_ area: AtlasAutonomosArea) -> Color {
        areaStateColorSoft(area) ?? AtlasTheme.domOperacional
    }
}
