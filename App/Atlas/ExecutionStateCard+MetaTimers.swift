import SwiftUI
import AtlasCore

// Timer lines — peel de ExecutionStateCard+Meta.
// Deadline → ExecutionStateCard+MetaDeadline.swift

extension ExecutionStateCard {
    @ViewBuilder
    var timerMetaLines: some View {
        if let frozen = frozenTimerText {
            Text(frozen)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        } else if let active = recoveringTimerText {
            Text(active)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
        deadlineMetaLine
    }
}
