import SwiftUI
import AtlasCore

// Fleet + health — peel de AutonomosLoadedSection+StackTail.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackTailFleet: some View {
        if let fleet = model.fleet {
            AutonomosFleetSection(
                fleet: fleet,
                incidentPresent: model.taskHealth?.incidents.present == true,
                auditModeEnabled: auditModeEnabled
            )
        }
        if let health = model.taskHealth {
            AutonomosTaskHealthSection(health: health)
        }
    }
}
