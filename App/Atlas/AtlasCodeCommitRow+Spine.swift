import SwiftUI
import AtlasCore

// Espinha do grafo — peel de AtlasCodeCommitRow (CICLO C residual honesty).
// Decorativa: spoken vive em AtlasCodeCommitRow+A11y.

extension AtlasCodeCommitRow {
    /// Linha contínua + nó. Cor via `AtlasCodePalette` (contrato); sem spoken.
    @ViewBuilder
    var spine: some View {
        let spineTint = color.opacity(0.45)
        let motion = AtlasMotionPresentation.editorial(reduceMotion: reduceMotion)
        VStack(spacing: 0) {
            spineConnector(fill: isFirst ? .clear : spineTint)
                .frame(height: 8)
            spineNode(motion: motion)
            spineConnector(fill: isLast ? .clear : spineTint)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 22)
        .animation(motion, value: state)
        .animation(motion, value: isFirst)
        .animation(motion, value: isLast)
        .atlasCodeGraphSpineDecorative()
    }

    private func spineConnector(fill: Color) -> some View {
        Rectangle()
            .fill(fill)
            .frame(width: 2)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func spineNode(motion: Animation?) -> some View {
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
