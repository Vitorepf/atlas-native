import SwiftUI
import AtlasCore

/// Kicker / checkpoint / timer / deadline — peel de ExecutionStateCard (régua ≤100).
/// Timers → ExecutionStateCard+MetaTimers.swift

extension ExecutionStateCard {
    @ViewBuilder var metaLines: some View {
        if let kicker = leaveScreenKicker {
            Text(kicker)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        if let checkpoint = state.checkpoint {
            Text("checkpoint · \(checkpoint)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
        timerMetaLines
    }
}
