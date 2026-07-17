import SwiftUI
import AtlasCore

// Metrics row — peel de AutonomosFleetSection+Summary.

extension AutonomosFleetSummary {
    @ViewBuilder
    var metricsSummaryRow: some View {
        HStack(spacing: 8) {
            FleetMetric(value: "\(fleet.agents.count)", label: "agentes registrados")
            FleetMetric(value: "\(fleet.agents.filter(\.alive).count)", label: "vivos agora")
            FleetMetric(value: "\(fleet.activeCount)", label: "ativos")
        }
    }
}
