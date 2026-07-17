import SwiftUI
import AtlasCore

// Row label — peel de AutonomosAreaPicker+Row.

extension AutonomosAreaPicker {
    func areaRowLabel(area: AtlasAutonomosArea, isSelected: Bool) -> some View {
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
}
