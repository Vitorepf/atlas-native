import SwiftUI
import AtlasCore

// Agent row chrome — peel de AutonomosFleetSection.
// Tags → AutonomosFleetSection+RowTags.swift

extension AutonomosFleetSection {
    @ViewBuilder
    func agentRow(_ agent: AtlasAutonomosFleetAgent, index: Int, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
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
            agentCompactTags(agent, compact: compact)
            agentAuditTags(agent)
        }
        .padding(12)
        .atlasCard(cornerRadius: 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AutonomosFleetSectionA11y.spokenAgent(
                agent,
                index: index,
                total: fleet.agents.count,
                compact: compact,
                auditModeEnabled: auditModeEnabled
            )
        )
        .accessibilityIdentifier(A11yID.autonomosFleetAgentRow(index))
    }
}
