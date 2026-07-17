import SwiftUI
import UIKit
import AtlasCore

// Diff/file preview — peel de ArtifactViewer+Preview.
// Diff → ArtifactViewer+DiffPreview.swift
// Markdown → ArtifactViewer+TextPreview+Markdown.swift
// File → ArtifactViewer+TextPreview+File.swift
// Document → ArtifactViewer+TextPreview+Document.swift

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishPreview: some View {
        switch item.kind {
        case .markdown, .text, .diff:
            textishDocumentPreview
        case .file:
            textishFilePreview
        default:
            EmptyView()
        }
    }
}
