import SwiftUI
import AtlasCore

// Incident body — peel de AutonomosTaskHealthSection.
// Quiet → AutonomosFleetTaskHealth+QuietBody.swift
// Incident card → AutonomosFleetTaskHealth+IncidentCard.swift
// Secondary → AutonomosFleetTaskHealth+SecondaryMetrics.swift

extension AutonomosTaskHealthSection {
    var incidentBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            AutonomosChrome.sectionCaption("SAÚDE DA FILA")
            HStack(spacing: 8) {
                FleetMetric(value: "\(health.tasks.servableNow)", label: "servíveis agora")
                FleetMetric(value: "\(health.tasks.claimed)", label: "reivindicadas")
                FleetMetric(value: "\(health.tasks.blocked)", label: "bloqueadas")
                FleetMetric(value: "\(health.leases.active)", label: "leases ativos")
            }
            .accessibilityHidden(true)
            .animation(reduceMotion ? nil : .default, value: health.tasks.servableNow)
            .animation(reduceMotion ? nil : .default, value: health.tasks.claimed)
            incidentSecondaryMetrics
            incidentCard
        }
    }
}
