import SwiftUI
import AtlasCore

// Fleet + health — peel de AutonomosLoadedSection+StackTail.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackTailFleet: some View {
        loadedStackTailFleetSection
        loadedStackTailTaskHealth
    }
}
