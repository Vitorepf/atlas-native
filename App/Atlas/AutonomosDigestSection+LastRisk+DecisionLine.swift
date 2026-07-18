import SwiftUI
import AtlasCore

// Decision line — peel de AutonomosDigestSection+LastRisk.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestDecisionLine(_ decision: AtlasAutonomosDigestPendingDecision) -> some View {
        (Text("decisão  ").font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            + Text(AutonomosChrome.plainSlugText(decision.title))
            .font(.caption).foregroundStyle(AtlasTheme.textSecondary))
            .lineLimit(2)
            .accessibilityHidden(true)
    }
}
