import SwiftUI
import UIKit
import AtlasCore

// Diff/file preview — peel de ArtifactViewer+Preview.

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishPreview: some View {
        switch item.kind {
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
        default:
            EmptyView()
        }
    }
}
