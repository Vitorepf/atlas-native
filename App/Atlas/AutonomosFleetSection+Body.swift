import SwiftUI
import AtlasCore

// Corpo da seção frota — peel de AutonomosFleetSection.

extension AutonomosFleetSection {
    @ViewBuilder
    var fleetSectionBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            if fleet.agents.isEmpty {
                AutonomosFleetEmptyState(kind: .noAgents)
            } else {
                AutonomosChrome.sectionCaption(incidentPresent ? "FROTA · ATENÇÃO" : "frota")
                if isQuiet && !auditModeEnabled {
                    Text("todos vivos · desejados · autorizados")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
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
