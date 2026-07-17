import SwiftUI
import UIKit
import AtlasCore

// Markdown/text preview branch — peel de ArtifactViewer+TextPreview.

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishDocumentPreview: some View {
        switch item.kind {
        case .markdown, .text:
            textishMarkdownPreview(content.data)
        case .diff:
            diffPreview
        default:
            EmptyView()
        }
    }
}
