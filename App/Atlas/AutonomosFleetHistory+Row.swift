import SwiftUI
import AtlasCore

// Event row — peel de AutonomosFleetHistory.

extension AutonomosFleetHistorySection {
    @ViewBuilder
    func historyEventRow(event: AtlasAutonomosFleetHistoryEvent, index: Int, visibleCount: Int) -> some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 0) {
                Circle()
                    .fill(index == 0 ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.35))
                    .frame(width: 7, height: 7)
                    .padding(.top, 5)
                if index < visibleCount - 1 {
                    Rectangle()
                        .fill(AtlasTheme.accent.opacity(0.18))
                        .frame(width: 1.5, height: 34)
                }
            }
            .accessibilityHidden(true)
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
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AutonomosFleetHistoryA11y.spokenEvent(event, index: index, visible: visibleCount)
        )
        .accessibilityIdentifier(A11yID.autonomosFleetHistoryRow(index))
    }
}
