import SwiftUI
import AtlasCore

// Header da área — peel de AutonomosAreaDetailSection.
// Metrics → AutonomosAreaDetailSection+Metrics.swift

extension AutonomosAreaDetailSection {
    var areaHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(area.areaName).font(AtlasFont.serif(24, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                Text(area.focus).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Spacer()
            Text("tier \(area.autonomyTier)/\(area.maxTierForArea)")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AutonomosAreaDetailA11y.spokenHeader(area: area, isPaused: model.live?.isPaused))
        .accessibilityAddTraits(.isHeader)
    }
}
