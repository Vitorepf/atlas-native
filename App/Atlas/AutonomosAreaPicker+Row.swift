import SwiftUI
import AtlasCore

// Row — peel de AutonomosAreaPicker.
// Phase → AutonomosAreaPicker+Phase.swift
// Label → AutonomosAreaPicker+RowLabel.swift
// A11y → AutonomosAreaPicker+Row+A11y.swift
// Button → AutonomosAreaPicker+Row+Button.swift

extension AutonomosAreaPicker {
    @ViewBuilder
    func areaRow(area: AtlasAutonomosArea, index: Int) -> some View {
        let isSelected = area.id == selectedAreaID
        areaRowA11y(
            areaRowButton(area: area, isSelected: isSelected),
            area: area,
            index: index,
            isSelected: isSelected
        )
    }
}
