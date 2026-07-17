import SwiftUI
import AtlasCore

// Espinha do grafo — peel de AtlasCodeCommitRow (CICLO C residual honesty).
// Decorativa: spoken vive em AtlasCodeCommitRow+A11y · Parts → +SpineParts.swift

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
}
