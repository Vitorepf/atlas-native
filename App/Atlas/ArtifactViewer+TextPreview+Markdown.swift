import SwiftUI
import UIKit
import AtlasCore

// Markdown preview branch — peel de ArtifactViewer+TextPreview.

extension ArtifactPreviewContent {
    @ViewBuilder
    func textishMarkdownPreview(_ content: Data) -> some View {
        AtlasMarkdownView(text: String(decoding: content, as: UTF8.self), streaming: false)
    }
}
