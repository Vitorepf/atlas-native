import SwiftUI
import UIKit
import AtlasCore

// Switch de preview por kind — peel de ArtifactViewer+Preview.

extension ArtifactPreviewContent {
    @ViewBuilder
    var previewSwitch: some View {
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
        default:
            textishPreview
        }
    }
}
