import SwiftUI
import AtlasCore

// Row — peel de AutonomosAreaPicker.
// Phase → AutonomosAreaPicker+Phase.swift
// Label → AutonomosAreaPicker+RowLabel.swift

extension AutonomosAreaPicker {
    @ViewBuilder
    func areaRow(area: AtlasAutonomosArea, index: Int) -> some View {
        let isSelected = area.id == selectedAreaID
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSelect(area.id)
        } label: {
            areaRowLabel(area: area, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AutonomosAreaPickerA11y.spokenRow(area, index: index, total: areas.count, isSelected: isSelected)
        )
        .accessibilityHint(AutonomosAreaPickerA11y.spokenRowHint())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier(A11yID.autonomosAreaPickerRow(index))
    }
}
