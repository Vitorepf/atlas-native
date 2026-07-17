import SwiftUI
import AtlasCore

// Trailing control (enviar / processando / menu) — peel de ComposerToolbar.
// Options → ComposerToolbar+Options.swift
// Send/processing → ComposerToolbar+TrailingSend.swift

extension ComposerToolbar {
    // Contexto fica atrás de uma única ação real. O modo, o esforço e o
    // workspace continuam disponíveis, sem disputar a atenção da escrita.
    @ViewBuilder var trailingControl: some View {
        trailingControlBranch
    }
}
