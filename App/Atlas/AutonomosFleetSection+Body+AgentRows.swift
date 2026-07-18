import SwiftUI
import AtlasCore

// Agent rows — peel de AutonomosFleetSection+Body.

extension AutonomosFleetSection {
    @ViewBuilder
    var fleetAgentRows: some View {
        AutonomosChrome.sectionCaption(incidentPresent ? "FROTA · ATENÇÃO" : "frota")
        fleetQuietCaption
        if isDormant && !auditModeEnabled && !dormantRowsExpanded {
            dormantCollapsedRow
        } else {
            ForEach(Array(fleet.agents.enumerated()), id: \.element.id) { index, agent in
                agentRow(
                    agent,
                    index: index,
                    compact: isQuiet && !auditModeEnabled && !AutonomosFleetHealth.agentNeedsAttention(agent)
                )
            }
        }
    }

    /// 5 cards de "off · não desejado · não autorizado" viram um sussurro só.
    var dormantCollapsedRow: some View {
        Button {
            if reduceMotion { dormantRowsExpanded = true } else {
                withAnimation(.easeOut(duration: 0.2)) { dormantRowsExpanded = true }
            }
        } label: {
            HStack(spacing: 6) {
                Text("\(fleet.agents.count) workers em repouso, por decisão sua · US$ \(String(format: "%.2f", fleet.agents.compactMap(\.spentUsd).reduce(0, +)))")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(fleet.agents.count) workers em repouso por decisão sua. Toque para ver cada um.")
        .accessibilityIdentifier(A11yID.autonomosFleetDormant)
    }
}
