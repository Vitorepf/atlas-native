import SwiftUI
import AtlasCore

// Agent rows — peel de AutonomosFleetSection+Body.

extension AutonomosFleetSection {
    @ViewBuilder
    var fleetAgentRows: some View {
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
