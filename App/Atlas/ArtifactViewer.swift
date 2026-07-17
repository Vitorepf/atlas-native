import SwiftUI
import UIKit
import AtlasCore

// Preview helpers do ArtifactSheet — fora do shell para a régua (~160).

enum ArtifactViewer {
    static func kindLabel(_ kind: AtlasTraceArtifacts.Item.Kind) -> String {
        switch kind {
        case .image: "imagem"
        case .markdown: "markdown"
        case .text: "texto"
        case .diff: "diff"
        case .file: "arquivo"
        }
    }

    static func byteLabel(_ bytes: Int) -> String {
        if bytes < 1_024 { return "\(bytes) B" }
        if bytes < 1_048_576 { return "\(max(1, bytes / 1_024)) KB" }
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.1f MB", mb).replacingOccurrences(of: ".", with: ",")
    }
}

struct ArtifactFileFicha: View {
    let name: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(AtlasFont.serif(17, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subtitle)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArtifactViewerA11y.spokenFicha(name: name, subtitle: subtitle))
    }
}

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
