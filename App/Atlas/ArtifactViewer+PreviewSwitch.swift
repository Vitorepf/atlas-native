import SwiftUI
import UIKit
import AtlasCore

// Switch de preview por kind — peel de ArtifactViewer+Preview.
// Decode → ArtifactViewer+PreviewDecode.swift

extension ArtifactPreviewContent {
    @ViewBuilder
    var previewSwitch: some View {
        switch item.kind {
        case .image:
            if let image = UIImage(data: content.data) {
                ZoomableArtifactImage(image: image, name: item.name)
            } else {
                imageDecodeFailure
            }
        default:
            textishPreview
        }
    }
}
