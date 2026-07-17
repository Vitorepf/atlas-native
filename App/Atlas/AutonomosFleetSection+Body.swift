import SwiftUI
import AtlasCore

// Corpo da seção frota — peel de AutonomosFleetSection.
// Quiet → AutonomosFleetSection+Quiet.swift

extension AutonomosFleetSection {
    @ViewBuilder
    var fleetSectionBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            if fleet.agents.isEmpty {
                fleetEmptyBranch
            } else {
                fleetAgentRows
            }
        }
    }
}
