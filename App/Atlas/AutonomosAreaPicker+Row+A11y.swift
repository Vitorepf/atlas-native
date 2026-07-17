import SwiftUI
import AtlasCore

// Row a11y — peel de AutonomosAreaPicker+Row.

extension AutonomosAreaPicker {
    func areaRowA11y<Content: View>(
        _ content: Content,
        area: AtlasAutonomosArea,
        index: Int,
        isSelected: Bool
    ) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                AutonomosAreaPickerA11y.spokenRow(area, index: index, total: areas.count, isSelected: isSelected)
            )
            .accessibilityHint(AutonomosAreaPickerA11y.spokenRowHint())
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityIdentifier(A11yID.autonomosAreaPickerRow(index))
    }
}
