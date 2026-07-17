import SwiftUI
import AtlasCore

// History + error — peel de AutonomosLoadedSection+StackTail.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackTailHistory: some View {
        loadedStackTailFleetHistory
        loadedStackTailControlError
    }
}
