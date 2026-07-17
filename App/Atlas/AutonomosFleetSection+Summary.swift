import SwiftUI
import AtlasCore

/// Frota global — summary quiet/metrics — peel de AutonomosFleetSection.
/// Quiet → AutonomosFleetSection+QuietLine.swift

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
            quietSummaryLine
        } else {
            HStack(spacing: 8) {
                FleetMetric(value: "\(fleet.agents.count)", label: "agentes registrados")
                FleetMetric(value: "\(fleet.agents.filter(\.alive).count)", label: "vivos agora")
                FleetMetric(value: "\(fleet.activeCount)", label: "ativos")
            }
        }
    }
}
