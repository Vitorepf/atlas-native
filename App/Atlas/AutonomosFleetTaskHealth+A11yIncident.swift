import Foundation
import AtlasCore

/// Incident spoken extras — peel de AutonomosFleetTaskHealth+A11y.
// Leases → AutonomosFleetTaskHealth+A11yIncident+Leases.swift
// Operating → AutonomosFleetTaskHealth+A11yIncident+Operating.swift

extension AutonomosTaskHealthA11y {
    static func spokenIncidentExtras(_ health: AtlasAutonomosTaskHealthResponse) -> [String] {
        var parts = spokenIncidentLeasesFlags(health)
        parts.append(contentsOf: spokenIncidentOperating(health))
        return parts
    }
}
