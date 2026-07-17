import SwiftUI
import AtlasCore

// Upper stack — peel de AutonomosAreaDetailSection+Body.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    var areaDetailUpperStack: some View {
        areaHeader
        areaObjectiveBlock
        metricsRow
        backlogDetailShortcuts
        placementSection
    }
}
