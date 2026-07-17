import SwiftUI
import AtlasCore

// Control error card — peel de AutonomosLoadedSection+StackTailHistory.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackTailControlError: some View {
        if let error = model.controlError {
            AutonomosErrorCard(message: error)
                .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 6)))
        }
    }
}
