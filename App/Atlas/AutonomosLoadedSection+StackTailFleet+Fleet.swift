import SwiftUI
import AtlasCore

// Fleet section — peel de AutonomosLoadedSection+StackTailFleet.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackTailFleetSection: some View {
        if let fleet = model.fleet {
            AutonomosFleetSection(
                fleet: fleet,
                incidentPresent: model.taskHealth?.incidents.present == true,
                auditModeEnabled: auditModeEnabled
            )
        }
    }
}
