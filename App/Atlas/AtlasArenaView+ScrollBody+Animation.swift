import SwiftUI
import AtlasCore

// Scroll animation — peel de AtlasArenaView+ScrollBody.

extension AtlasArenaView {
    func arenaScrollAnimated(_ stack: some View) -> some View {
        stack
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.regressionException != nil)
    }
}
