import SwiftUI
import AtlasCore

// Empty branch — peel de AutonomosFleetSection+Body.

extension AutonomosFleetSection {
    @ViewBuilder
    var fleetEmptyBranch: some View {
        AutonomosFleetEmptyState(kind: .noAgents)
    }
}
