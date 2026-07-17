import SwiftUI
import AtlasCore

// Estados tooLarge/failed do preview — peel de ArtifactSheet+PreviewStates.

extension ArtifactSheet {
    @ViewBuilder
    func previewPaneFailure(bytes: Int? = nil, message: String? = nil) -> some View {
        if let bytes {
            ArtifactFileFicha(
                name: selected?.name ?? "artefato",
                subtitle: "grande demais para visualizar aqui · \(ArtifactViewer.byteLabel(bytes))"
            )
            .accessibilityLabel(
                ArtifactViewerA11y.spokenTooLarge(
                    name: selected?.name ?? "artefato",
                    bytes: bytes
                )
            )
        } else if let message {
            Text(message)
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.domOperacional)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("preview falhou, \(message)")
        }
    }
}
