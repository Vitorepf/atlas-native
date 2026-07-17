import SwiftUI
import AtlasCore

/// Frota global — summary quiet/metrics — peel de AutonomosFleetSection.
/// Quiet → AutonomosFleetSection+QuietLine.swift
/// Empty → AutonomosFleetSection+Summary+Empty.swift
/// Health → AutonomosFleetSection+Summary+Health.swift

struct AutonomosFleetSummary: View {
    let fleet: AtlasAutonomosFleetResponse
    var incidentPresent: Bool = false

    var isQuiet: Bool {
        AutonomosFleetHealth.isQuiet(fleet: fleet, incidentPresent: incidentPresent)
    }

    var body: some View {
        if fleet.agents.isEmpty {
            summaryEmptyBranch
        } else {
            summaryHealthBranch
        }
    }
}
