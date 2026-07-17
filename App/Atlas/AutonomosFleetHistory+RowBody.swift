import SwiftUI
import AtlasCore

// Event body text — peel de AutonomosFleetHistory+Row.
// Tags → AutonomosFleetHistory+RowTags.swift

extension AutonomosFleetHistorySection {
    @ViewBuilder
    func historyEventBody(event: AtlasAutonomosFleetHistoryEvent) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(event.event)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            historyEventTags(event: event)
            if let reason = event.reason?.nonEmpty {
                Text(reason)
                    .font(.caption2)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            Text(event.at)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
