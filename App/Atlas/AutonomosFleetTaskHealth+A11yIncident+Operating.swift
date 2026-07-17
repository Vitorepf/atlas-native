import Foundation
import AtlasCore

// Operating spoken — peel de AutonomosFleetTaskHealth+A11yIncident.
// Leases → AutonomosFleetTaskHealth+A11yIncident+Leases.swift

extension AutonomosTaskHealthA11y {
    static func spokenIncidentOperating(_ health: AtlasAutonomosTaskHealthResponse) -> [String] {
        var parts: [String] = []
        let pressure = health.operating.queuePressure.trimmingCharacters(in: .whitespacesAndNewlines)
        if !pressure.isEmpty {
            parts.append("pressão \(pressure)")
        }
        let action = health.operating.recommendedAction.trimmingCharacters(in: .whitespacesAndNewlines)
        if !action.isEmpty {
            parts.append(action)
        }
        return parts
    }
}
