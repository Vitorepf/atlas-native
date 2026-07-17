import SwiftUI
import AtlasCore

// History + error — peel de AutonomosLoadedSection+StackTail.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackTailHistory: some View {
        if let history = model.fleetHistory {
            AutonomosFleetHistorySection(history: history)
        }
        if let error = model.controlError {
            AutonomosErrorCard(message: error)
                .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 6)))
        }
    }
}
