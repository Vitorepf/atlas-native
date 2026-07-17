import SwiftUI
import AtlasCore

/// Frota global — summary quiet/metrics — peel de AutonomosFleetSection.

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
