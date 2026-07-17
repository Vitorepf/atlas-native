import SwiftUI
import AtlasCore

// Decision line — peel de AutonomosDigestSection+LastRisk.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestDecisionLine(_ decision: AtlasAutonomosDigestPendingDecision) -> some View {
        Text(decision.title)
            .font(.caption)
            .foregroundStyle(AtlasTheme.textSecondary)
            .lineLimit(2)
            .accessibilityHidden(true)
    }
}
