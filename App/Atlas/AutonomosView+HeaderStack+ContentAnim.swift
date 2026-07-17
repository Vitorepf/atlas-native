import SwiftUI
import AtlasCore

// Content animation — peel de AutonomosView+HeaderStack.

extension AutonomosView {
    var autonomosContentAnimated: some View {
        content
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
    }
}
