import SwiftUI
import AtlasCore

// History reason/time — peel de AutonomosFleetHistory+RowBody.

extension AutonomosFleetHistorySection {
    @ViewBuilder
    func historyEventMeta(event: AtlasAutonomosFleetHistoryEvent) -> some View {
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
