import SwiftUI
import AtlasCore

// Code screen shell chrome — peel de AtlasCodeView.

extension AtlasCodeView {
    func codeScreenChrome<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Grafo")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier(A11yID.codeScreen)
            .accessibilityLabel(spokenCodeScreenLabel())
            .accessibilityHint(Self.codeScreenHint)
            .toolbar { codeToolbar }
            .task { if model.phase == .idle { await model.load() } }
            .task { await mirrorModel.refresh() }
    }
}
