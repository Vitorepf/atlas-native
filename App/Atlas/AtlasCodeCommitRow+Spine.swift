import SwiftUI
import AtlasCore

// Espinha do grafo — peel de AtlasCodeCommitRow (CICLO C residual honesty).
// Decorativa: spoken vive em AtlasCodeCommitRow+A11y · Parts → +SpineParts.swift
// Column → AtlasCodeCommitRow+Spine+Column.swift

extension AtlasCodeCommitRow {
    /// Linha contínua + nó. Cor via `AtlasCodePalette` (contrato); sem spoken.
    @ViewBuilder
    var spine: some View {
        let spineTint = color.opacity(0.45)
        let motion = AtlasMotionPresentation.editorial(reduceMotion: reduceMotion)
        spineColumn(spineTint: spineTint, motion: motion)
    }
}
