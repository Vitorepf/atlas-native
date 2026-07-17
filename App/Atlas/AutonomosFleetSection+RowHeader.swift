import SwiftUI
import AtlasCore

// Agent row header — peel de AutonomosFleetSection+Row.

extension AutonomosFleetSection {
    func agentRowHeader(_ agent: AtlasAutonomosFleetAgent) -> some View {
        HStack(spacing: 8) {
            Circle().fill(agent.alive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            Text(agent.label).font(.system(.footnote, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Spacer()
            Text(agent.status).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .accessibilityHidden(true)
    }
}
