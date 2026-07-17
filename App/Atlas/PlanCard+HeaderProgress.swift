import SwiftUI
import AtlasCore

// Progress badge — peel de PlanCard+Header.

extension PlanCard {
    @ViewBuilder
    func planHeaderProgress(_ progress: ChatBubble.ExecutionProgress) -> some View {
        Text("\(progress.current)/\(progress.total)")
            .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityLabel(spokenProgressBadge(progress))
            .accessibilityIdentifier(A11yID.planProgress)
    }
}
