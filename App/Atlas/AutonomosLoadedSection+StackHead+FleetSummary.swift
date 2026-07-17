import SwiftUI
import AtlasCore

// Fleet summary — peel de AutonomosLoadedSection+StackHead.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackHeadFleetSummary: some View {
        if let fleet = model.fleet {
            AutonomosFleetSummary(
                fleet: fleet,
                incidentPresent: model.taskHealth?.incidents.present == true
            )
        }
    }
}
