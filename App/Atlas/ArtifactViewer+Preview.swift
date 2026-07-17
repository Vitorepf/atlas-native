import SwiftUI
import UIKit
import AtlasCore

// Preview do conteúdo — peel de ArtifactViewer.

struct ArtifactPreviewContent: View {
    let item: AtlasTraceArtifacts.Item
    let content: AtlasArtifactContent

    var body: some View {
        Group {
            switch item.kind {
            case .image:
                if let image = UIImage(data: content.data) {
                    ZoomableArtifactImage(image: image, name: item.name)
                } else {
                    ArtifactFileFicha(
                        name: item.name,
                        subtitle: "imagem não pôde ser decodificada · \(ArtifactViewer.byteLabel(item.byteSize))"
                    )
                    .accessibilityLabel(
                        ArtifactViewerA11y.spokenDecodeFailure(name: item.name, bytes: item.byteSize)
                    )
                }
            case .markdown, .text:
                AtlasMarkdownView(text: String(decoding: content.data, as: UTF8.self), streaming: false)
            case .diff:
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(String(decoding: content.data, as: UTF8.self))
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 360)
                .accessibilityElement(children: .contain)
                .accessibilityLabel(ArtifactViewerA11y.spokenPreview(item: item))
                .accessibilityHint("arraste horizontalmente para ler o diff")
            case .file:
                ArtifactFileFicha(
                    name: item.name,
                    subtitle: "\(ArtifactViewer.byteLabel(item.byteSize)) · sha \(String(item.sha256.prefix(12)))"
                )
            }
        }
    }
}
