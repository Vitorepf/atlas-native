import Foundation
import AtlasCore

// Leases/flags spoken — peel de AutonomosFleetTaskHealth+A11yIncident.
// Operating → AutonomosFleetTaskHealth+A11yIncident+Operating.swift

extension AutonomosTaskHealthA11y {
    static func spokenIncidentLeasesFlags(_ health: AtlasAutonomosTaskHealthResponse) -> [String] {
        var parts: [String] = []
        if !health.leases.matchesClaimed {
            parts.append("leases não batem com tarefas reivindicadas")
        }
        if !health.incidents.flags.isEmpty {
            parts.append(health.incidents.flags.joined(separator: ", "))
        }
        return parts
    }
}
