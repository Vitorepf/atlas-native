import SwiftUI
import AtlasCore

/// Frota global — agentes reais, saúde da fila, histórico e handoff (C13).
/// Task health → AutonomosFleetTaskHealth.swift · histórico → AutonomosFleetHistory.swift · transfer → AutonomosFleetTransfer.swift.
struct AutonomosFleetSummary: View {
    let fleet: AtlasAutonomosFleetResponse
    var incidentPresent: Bool = false

    private var isQuiet: Bool {
        AutonomosFleetHealth.isQuiet(fleet: fleet, incidentPresent: incidentPresent)
    }

    var body: some View {
        if fleet.agents.isEmpty {
            AutonomosFleetEmptyState(kind: .noAgents)
        } else if isQuiet {
            Text("\(fleet.agents.count) agente\(fleet.agents.count == 1 ? "" : "s") · \(fleet.activeCount) ativo\(fleet.activeCount == 1 ? "" : "s") · silêncio")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("frota quieta, \(fleet.agents.count) agentes, \(fleet.activeCount) ativos")
                .accessibilityIdentifier(A11yID.autonomosFleetQuiet)
        } else {
            HStack(spacing: 8) {
                FleetMetric(value: "\(fleet.agents.count)", label: "agentes registrados")
                FleetMetric(value: "\(fleet.agents.filter(\.alive).count)", label: "vivos agora")
                FleetMetric(value: "\(fleet.activeCount)", label: "ativos")
            }
        }
    }
}

struct AutonomosFleetSection: View {
    let fleet: AtlasAutonomosFleetResponse
    /// Incidente da fila (C13) — saudável = header quieto; barulho só por exceção.
    var incidentPresent: Bool = false
    var auditModeEnabled: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isQuiet: Bool {
        AutonomosFleetHealth.isQuiet(fleet: fleet, incidentPresent: incidentPresent)
    }

    var body: some View {
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            AutonomosFleetSectionA11y.spokenSection(
                agentCount: fleet.agents.count,
                activeCount: fleet.activeCount,
                incidentPresent: incidentPresent,
                isQuiet: isQuiet && !auditModeEnabled
            )
        )
        .accessibilityIdentifier(A11yID.autonomosFleetSection)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: isQuiet)
    }
}
