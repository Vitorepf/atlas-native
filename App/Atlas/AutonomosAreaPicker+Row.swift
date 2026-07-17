import SwiftUI
import AtlasCore

// Row — peel de AutonomosAreaPicker.
// Phase → AutonomosAreaPicker+Phase.swift
// Label → AutonomosAreaPicker+RowLabel.swift
// A11y → AutonomosAreaPicker+Row+A11y.swift

extension AutonomosAreaPicker {
    @ViewBuilder
    func areaRow(area: AtlasAutonomosArea, index: Int) -> some View {
        let isSelected = area.id == selectedAreaID
        areaRowA11y(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onSelect(area.id)
            } label: {
                areaRowLabel(area: area, isSelected: isSelected)
            }
            .buttonStyle(.plain),
            area: area,
            index: index,
            isSelected: isSelected
        )
    }
}
