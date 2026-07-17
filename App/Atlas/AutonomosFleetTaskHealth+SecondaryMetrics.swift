import SwiftUI
import AtlasCore

// Incident metrics row 2 — peel de AutonomosFleetTaskHealth+Bodies.

extension AutonomosTaskHealthSection {
    var incidentSecondaryMetrics: some View {
        HStack(spacing: 8) {
            FleetMetric(value: "\(health.tasks.completed)", label: "completas")
            FleetMetric(value: "\(health.tasks.recoverable)", label: "recuperáveis")
        }
        .accessibilityHidden(true)
        .animation(reduceMotion ? nil : .default, value: health.tasks.completed)
    }
}
