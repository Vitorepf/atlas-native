import SwiftUI
import AtlasCore

// Fleet history — peel de AutonomosLoadedSection+StackTailHistory.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackTailFleetHistory: some View {
        if let history = model.fleetHistory {
            AutonomosFleetHistorySection(history: history)
        }
    }
}
