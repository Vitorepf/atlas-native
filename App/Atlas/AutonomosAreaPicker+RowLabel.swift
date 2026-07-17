import SwiftUI
import AtlasCore

// Row label — peel de AutonomosAreaPicker+Row.
// Chrome → AutonomosAreaPicker+RowLabel+Chrome.swift
// NameStack → AutonomosAreaPicker+RowLabel+NameStack.swift

extension AutonomosAreaPicker {
    func areaRowLabel(area: AtlasAutonomosArea, isSelected: Bool) -> some View {
        areaRowLabelChrome(
            HStack(spacing: 10) {
                Circle().fill(areaStateColor(area)).frame(width: 8, height: 8)
                    .accessibilityHidden(true)
                areaRowNameStack(area: area)
                Spacer()
                Text(areaStateLabel(area)).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            },
            isSelected: isSelected
        )
    }
}
