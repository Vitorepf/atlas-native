import SwiftUI
import AtlasCore

// Metric HStack — peel de AutonomosFleetTaskHealth+Bodies.

extension AutonomosTaskHealthSection {
    var incidentMetricRow: some View {
        HStack(spacing: 8) {
            FleetMetric(value: "\(health.tasks.servableNow)", label: "servíveis agora")
            FleetMetric(value: "\(health.tasks.claimed)", label: "reivindicadas")
            FleetMetric(value: "\(health.tasks.blocked)", label: "bloqueadas")
            FleetMetric(value: "\(health.leases.active)", label: "leases ativos")
        }
        .accessibilityHidden(true)
        .animation(reduceMotion ? nil : .default, value: health.tasks.servableNow)
        .animation(reduceMotion ? nil : .default, value: health.tasks.claimed)
    }
}
