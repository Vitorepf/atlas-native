import SwiftUI
import AtlasCore

// Awaiting + picker do stack — peel de AutonomosLoadedSection+Stack.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackMid: some View {
        loadedStackMidAwaiting
        loadedStackMidAreaPicker
        loadedAreaDetail
    }
}
