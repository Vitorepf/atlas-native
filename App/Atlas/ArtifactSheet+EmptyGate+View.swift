import SwiftUI
import AtlasCore

// Empty visual — peel de ArtifactSheet+EmptyGate.

extension ArtifactSheet {
    @ViewBuilder
    var emptyVisualizable: some View {
        Text("nenhum artefato visualizável")
            .font(AtlasFont.serifItalic(15))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier(A11yID.artifactsEmpty)
            .accessibilityLabel("sem artefatos visualizáveis nesta execução")
    }
}
