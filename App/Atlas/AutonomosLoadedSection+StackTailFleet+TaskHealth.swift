import SwiftUI
import AtlasCore

// Task health — peel de AutonomosLoadedSection+StackTailFleet.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackTailTaskHealth: some View {
        if let health = model.taskHealth {
            AutonomosTaskHealthSection(health: health)
        }
    }
}
