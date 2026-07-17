import SwiftUI
import AtlasCore

// Agent row chrome — peel de AutonomosFleetSection.
// Tags → AutonomosFleetSection+RowTags.swift
// Header → AutonomosFleetSection+RowHeader.swift
// A11y → AutonomosFleetSection+RowA11y.swift

extension AutonomosFleetSection {
    @ViewBuilder
    func agentRow(_ agent: AtlasAutonomosFleetAgent, index: Int, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            agentRowHeader(agent)
            agentCompactTags(agent, compact: compact)
            agentAuditTags(agent)
        }
        .padding(12)
        .atlasCard(cornerRadius: 12)
        .autonomosFleetAgentA11y(
            agent: agent,
            index: index,
            total: fleet.agents.count,
            compact: compact,
            auditModeEnabled: auditModeEnabled
        )
    }
}
