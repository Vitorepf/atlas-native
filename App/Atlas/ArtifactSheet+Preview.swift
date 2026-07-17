import SwiftUI
import AtlasCore

// Preview pane + load — peel de ArtifactSheet+Content.

extension ArtifactSheet {
    @ViewBuilder
    var previewPane: some View {
        VStack(alignment: .leading, spacing: 10) {
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
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasCard()
    }

    func load(_ item: AtlasTraceArtifacts.Item) async {
        preview = .loading
        do {
            let content = try await reviews.loadArtifactContent(traceId: traceId, item: item)
            preview = .loaded(item, content)
        } catch let api as AtlasApiError where api.status == 413 {
            preview = .tooLarge(item.byteSize)
        } catch {
            preview = .failed(atlasUserMessage(for: error))
        }
    }
}

enum ArtifactPreviewState {
    case idle
    case loading
    case loaded(AtlasTraceArtifacts.Item, AtlasArtifactContent)
    case tooLarge(Int)
    case failed(String)
}
