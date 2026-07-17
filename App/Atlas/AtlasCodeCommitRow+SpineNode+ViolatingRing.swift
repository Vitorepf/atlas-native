import SwiftUI
import AtlasCore

// Violating ring — peel de AtlasCodeCommitRow+SpineNode.

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineViolatingRing(motion: Animation?) -> some View {
        if state == .violating {
            Circle()
                .strokeBorder(color.opacity(0.5), lineWidth: 1.4)
                .frame(width: 22, height: 22)
                .accessibilityHidden(true)
                .transition(AtlasMotionPresentation.rowTransition(reduceMotion: reduceMotion))
        }
    }
}
