import SwiftUI
import UIKit
import AtlasCore

// Diff/file preview — peel de ArtifactViewer+Preview.
// Diff → ArtifactViewer+DiffPreview.swift

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishPreview: some View {
        switch item.kind {
        case .markdown, .text:
            AtlasMarkdownView(text: String(decoding: content.data, as: UTF8.self), streaming: false)
        case .diff:
            diffPreview
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
