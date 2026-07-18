import SwiftUI
import AtlasCore

// Risk line — peel de AutonomosDigestSection+LastRisk.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestRiskLine(_ risk: AtlasAutonomosDigestRisk) -> some View {
        (Text("risco  ").font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            + Text(AutonomosChrome.plainSlugText(risk.title?.nonEmpty ?? risk.reason?.nonEmpty ?? risk.severity))
            .font(.caption).foregroundStyle(AtlasTheme.textSecondary))
            .lineLimit(2)
            .accessibilityHidden(true)
    }
}
