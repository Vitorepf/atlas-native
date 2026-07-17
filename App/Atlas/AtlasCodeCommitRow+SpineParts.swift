import SwiftUI
import AtlasCore

// Node/connector — peel de AtlasCodeCommitRow+Spine.

extension AtlasCodeCommitRow {
    func spineConnector(fill: Color) -> some View {
        Rectangle()
            .fill(fill)
            .frame(width: 2)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    func spineNode(motion: Animation?) -> some View {
        ZStack {
            if state == .violating {
                Circle()
                    .strokeBorder(color.opacity(0.5), lineWidth: 1.4)
                    .frame(width: 22, height: 22)
                    .accessibilityHidden(true)
                    .transition(AtlasMotionPresentation.rowTransition(reduceMotion: reduceMotion))
            }
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
                .overlay(Circle().strokeBorder(AtlasTheme.bg, lineWidth: 2))
                .accessibilityHidden(true)
        }
        .frame(width: 22, height: 22)
        .animation(motion, value: state == .violating)
    }
}
