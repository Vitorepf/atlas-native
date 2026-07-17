import SwiftUI
import AtlasCore

// Row — peel de AutonomosAreaPicker.
// Phase → AutonomosAreaPicker+Phase.swift

extension AutonomosAreaPicker {
    @ViewBuilder
    func areaRow(area: AtlasAutonomosArea, index: Int) -> some View {
        let isSelected = area.id == selectedAreaID
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSelect(area.id)
        } label: {
            HStack(spacing: 10) {
                Circle().fill(areaStateColor(area)).frame(width: 8, height: 8)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(area.areaName).font(.system(.footnote, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityHidden(true)
                    Text(area.objective).font(.caption).foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                        .accessibilityHidden(true)
                }
                Spacer()
                Text(areaStateLabel(area)).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(isSelected ? AtlasTheme.surfaceHi : AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
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
