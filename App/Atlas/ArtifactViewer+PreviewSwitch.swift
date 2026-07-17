import SwiftUI
import UIKit
import AtlasCore

// Switch de preview por kind — peel de ArtifactViewer+Preview.
// Decode → ArtifactViewer+PreviewDecode.swift
// Image → ArtifactViewer+PreviewImage.swift

extension ArtifactPreviewContent {
    @ViewBuilder
    var previewSwitch: some View {
        switch item.kind {
        case .image:
            imagePreviewBranch
        default:
            textishPreview
        }
    }
}
