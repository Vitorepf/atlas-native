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
                        .accessibilityLabel("frota saudável, todos vivos desejados e autorizados")
                }
                ForEach(fleet.agents) { agent in
                    agentRow(agent, compact: isQuiet && !auditModeEnabled && !AutonomosFleetHealth.agentNeedsAttention(agent))
                }
            }
        }
    }

    @ViewBuilder
    private func agentRow(_ agent: AtlasAutonomosFleetAgent, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Circle().fill(agent.alive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                    .frame(width: 7, height: 7)
                Text(agent.label).font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer()
                Text(agent.status).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
            }
            if !compact {
                HStack(spacing: 10) {
                    if let up = agent.uptimeSeconds { AutonomosChrome.tag("↑ " + AutonomosChrome.uptime(up)) }
                    if !agent.pids.isEmpty { AutonomosChrome.tag("\(agent.pids.count) pid\(agent.pids.count == 1 ? "" : "s")") }
                    if let spent = agent.spentUsd { AutonomosChrome.tag(String(format: "US$ %.2f", spent)) }
                    AutonomosChrome.tag(agent.desired ? "desejado" : "não desejado")
                    AutonomosChrome.tag(agent.authorized ? "autorizado" : "não autorizado")
                }
            }
            if auditModeEnabled {
                HStack(spacing: 6) {
                    AutonomosChrome.tag(agent.account)
                    AutonomosChrome.tag(agent.kind)
                    if let ttl = agent.ttlRemainingSeconds { AutonomosChrome.tag("ttl \(ttl)s") }
                    if let budget = agent.budgetLimitUsd { AutonomosChrome.tag(String(format: "limite %.2f", budget)) }
                    if let target = agent.targetRef?.nonEmpty { AutonomosChrome.tag(target) }
                }
                if let reason = agent.reason?.nonEmpty {
                    Text(reason)
                        .font(.caption2)
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                }
            }
        }
        .padding(12)
        .atlasCard(cornerRadius: 12)
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
