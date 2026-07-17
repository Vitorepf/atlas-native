import SwiftUI
import AtlasCore

// Preview loaded / failed branches — peel de ArtifactSheet+Preview.

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneStates: some View {
        switch preview {
        case .idle, .loading:
            TraceEvidenceLoading(text: "carregando preview…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity, minHeight: 180)
        case .tooLarge(let bytes):
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
        case .failed(let message):
            Text(message)
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.domOperacional)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("preview falhou, \(message)")
        case .loaded(let item, let content):
            ArtifactPreviewContent(item: item, content: content)
        }
    }
}
