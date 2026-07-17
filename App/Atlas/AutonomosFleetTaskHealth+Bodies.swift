import SwiftUI
import AtlasCore

// Incident body — peel de AutonomosTaskHealthSection.
// Quiet → AutonomosFleetTaskHealth+QuietBody.swift
// Incident card → AutonomosFleetTaskHealth+IncidentCard.swift

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
            HStack(spacing: 8) {
                FleetMetric(value: "\(health.tasks.completed)", label: "completas")
                FleetMetric(value: "\(health.tasks.recoverable)", label: "recuperáveis")
            }
            .accessibilityHidden(true)
            .animation(reduceMotion ? nil : .default, value: health.tasks.completed)
            incidentCard
        }
    }
}
