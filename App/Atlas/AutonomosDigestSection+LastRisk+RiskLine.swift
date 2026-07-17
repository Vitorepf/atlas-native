import SwiftUI
import AtlasCore

// Risk line — peel de AutonomosDigestSection+LastRisk.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestRiskLine(_ risk: AtlasAutonomosDigestRisk) -> some View {
        Text(risk.title?.nonEmpty ?? risk.reason?.nonEmpty ?? risk.severity)
            .font(.caption)
            .foregroundStyle(AtlasTheme.textSecondary)
            .lineLimit(2)
            .accessibilityHidden(true)
    }
}
