import SwiftUI
import AtlasCore

// Corpo da seção frota — peel de AutonomosFleetSection.
// Quiet → AutonomosFleetSection+Quiet.swift

extension AutonomosFleetSection {
    @ViewBuilder
    var fleetSectionBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            if fleet.agents.isEmpty {
                AutonomosFleetEmptyState(kind: .noAgents)
            } else {
                AutonomosChrome.sectionCaption(incidentPresent ? "FROTA · ATENÇÃO" : "frota")
                fleetQuietCaption
                ForEach(Array(fleet.agents.enumerated()), id: \.element.id) { index, agent in
                    agentRow(
                        agent,
                        index: index,
                        compact: isQuiet && !auditModeEnabled && !AutonomosFleetHealth.agentNeedsAttention(agent)
                    )
                }
            }
        }
    }
}
