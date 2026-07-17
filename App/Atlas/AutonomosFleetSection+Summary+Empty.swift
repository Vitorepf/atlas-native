import SwiftUI
import AtlasCore

/// Frota summary empty branch — peel de AutonomosFleetSection+Summary.

extension AutonomosFleetSummary {
    @ViewBuilder
    var summaryEmptyBranch: some View {
        AutonomosFleetEmptyState(kind: .noAgents)
    }
}
