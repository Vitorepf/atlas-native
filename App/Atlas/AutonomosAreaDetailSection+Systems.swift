import SwiftUI
import AtlasCore

// Sistemas sob responsabilidade — peel de AutonomosAreaDetailSection+Metrics.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    var ownedSystemsBlock: some View {
        if !area.ownedSystems.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text("SISTEMAS SOB RESPONSABILIDADE").font(AtlasFont.mono(10)).tracking(0.9).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text(area.ownedSystems.joined(separator: " · ")).font(.caption).foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosAreaDetailA11y.spokenOwnedSystems(area.ownedSystems))
        }
    }
}
