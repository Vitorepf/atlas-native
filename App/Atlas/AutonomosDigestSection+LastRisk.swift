import SwiftUI
import AtlasCore

// Last digest risk/decision — peel de AutonomosDigestSection+Last.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestRiskDecision(_ digest: AtlasAutonomosDigestResponse) -> some View {
        if let risk = digest.last.risks.first {
            Text(risk.title?.nonEmpty ?? risk.reason?.nonEmpty ?? risk.severity)
                .font(.caption)
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
        if let decision = digest.last.pendingDecisions.first {
            Text(decision.title)
                .font(.caption)
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}
