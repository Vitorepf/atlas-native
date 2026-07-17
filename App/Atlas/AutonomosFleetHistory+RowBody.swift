import SwiftUI
import AtlasCore

// Event body text — peel de AutonomosFleetHistory+Row.

extension AutonomosFleetHistorySection {
    @ViewBuilder
    func historyEventBody(event: AtlasAutonomosFleetHistoryEvent) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(event.event)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            HStack(spacing: 6) {
                AutonomosChrome.tag(event.agentKey)
                if let by = event.by?.nonEmpty { AutonomosChrome.tag(by) }
                if let account = event.account?.nonEmpty { AutonomosChrome.tag(account) }
                if let pid = event.pid { AutonomosChrome.tag("pid \(pid)") }
                if let duration = event.durationSeconds { AutonomosChrome.tag(AutonomosChrome.uptime(duration)) }
            }
            .accessibilityHidden(true)
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
