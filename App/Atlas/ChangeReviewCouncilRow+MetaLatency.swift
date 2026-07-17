import SwiftUI
import AtlasCore

// Latency chip — peel de ChangeReviewCouncilRow+Meta.

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaLatency: some View {
        if let latency = member.latencyMs {
            Text("\(latency)ms")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}
