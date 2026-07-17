import SwiftUI
import UIKit
import AtlasCore

// Diff/file preview — peel de ArtifactViewer+Preview.
// Diff → ArtifactViewer+DiffPreview.swift
// Markdown → ArtifactViewer+TextPreview+Markdown.swift
// File → ArtifactViewer+TextPreview+File.swift

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishPreview: some View {
        switch item.kind {
        case .markdown, .text:
            textishMarkdownPreview(content.data)
        case .diff:
            diffPreview
        case .file:
            textishFilePreview
        default:
            EmptyView()
        }
    }
}
