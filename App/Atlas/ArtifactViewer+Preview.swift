import SwiftUI
import UIKit
import AtlasCore

// Preview do conteúdo — peel de ArtifactViewer.
// Text/diff/file → ArtifactViewer+TextPreview.swift
// Switch → ArtifactViewer+PreviewSwitch.swift

struct ArtifactPreviewContent: View {
    let item: AtlasTraceArtifacts.Item
    let content: AtlasArtifactContent

    var body: some View {
        Group { previewSwitch }
    }
}
