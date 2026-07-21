import SwiftUI
import UIKit
import AtlasCore

// Decode failure ficha — peel de ArtifactViewer+PreviewSwitch.

extension ArtifactPreviewContent {
    var imageDecodeFailure: some View {
        ArtifactFileFicha(
            name: item.name,
            subtitle: "imagem não pôde ser decodificada · \(ArtifactViewer.byteLabel(item.byteSize))"
        )
        .accessibilityLabel(
            ArtifactViewerA11y.spokenDecodeFailure(name: item.name, bytes: item.byteSize)
        )
    }
}
