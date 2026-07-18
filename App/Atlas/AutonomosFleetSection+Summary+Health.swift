import SwiftUI
import AtlasCore

/// Frota summary quiet/metrics branch — peel de AutonomosFleetSection+Summary.

extension AutonomosFleetSummary {
    @ViewBuilder
    var summaryHealthBranch: some View {
        if isQuiet {
            quietSummaryLine
        } else if AutonomosFleetHealth.isDormant(fleet: fleet) {
            dormantSummaryLine
        } else {
            metricsSummaryRow
        }
    }
}
