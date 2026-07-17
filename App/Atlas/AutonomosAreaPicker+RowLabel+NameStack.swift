import SwiftUI
import AtlasCore

// Name/objective stack — peel de AutonomosAreaPicker+RowLabel.

extension AutonomosAreaPicker {
    func areaRowNameStack(area: AtlasAutonomosArea) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(area.areaName).font(.system(.footnote, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(area.objective).font(.caption).foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
