import Foundation
import AtlasCore

/// Incident spoken extras — peel de AutonomosFleetTaskHealth+A11y.

extension AutonomosTaskHealthA11y {
    static func spokenIncidentExtras(_ health: AtlasAutonomosTaskHealthResponse) -> [String] {
        var parts: [String] = []
        if !health.leases.matchesClaimed {
            parts.append("leases não batem com tarefas reivindicadas")
        }
        if !health.incidents.flags.isEmpty {
            parts.append(health.incidents.flags.joined(separator: ", "))
        }
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
