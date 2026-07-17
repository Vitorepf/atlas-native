import SwiftUI
import AtlasCore

// Incident body — peel de AutonomosTaskHealthSection.
// Quiet → AutonomosFleetTaskHealth+QuietBody.swift
// Incident card → AutonomosFleetTaskHealth+IncidentCard.swift
// Secondary → AutonomosFleetTaskHealth+SecondaryMetrics.swift
// MetricRow → AutonomosFleetTaskHealth+Bodies+MetricRow.swift

extension AutonomosTaskHealthSection {
    var incidentBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            AutonomosChrome.sectionCaption("SAÚDE DA FILA")
            incidentMetricRow
            incidentSecondaryMetrics
            incidentCard
        }
    }
}
