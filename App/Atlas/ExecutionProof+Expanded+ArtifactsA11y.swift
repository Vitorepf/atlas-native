import SwiftUI
import AtlasCore

// A11y do botão de artefatos — peel de ExecutionProof+Expanded+Artifacts.

extension ExecutionProof {
    func artifactsButtonA11y<Content: View>(_ content: Content, count: Int) -> some View {
        content
            .buttonStyle(.plain)
            .accessibilityIdentifier(A11yID.artifactsRow)
            .accessibilityLabel("artefatos desta execução, \(count)")
            .accessibilityHint("abre a lista de artefatos deste trace")
    }
}
