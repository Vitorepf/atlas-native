import SwiftUI
import UIKit
import AtlasCore

// Preview do conteúdo — peel de ArtifactViewer.
// Text/diff/file → ArtifactViewer+TextPreview.swift

struct ArtifactPreviewContent: View {
    let item: AtlasTraceArtifacts.Item
    let content: AtlasArtifactContent

    var body: some View {
        Group {
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
}
