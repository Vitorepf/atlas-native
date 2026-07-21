import SwiftUI
import UIKit
import AtlasCore

// File ficha preview branch — peel de ArtifactViewer+TextPreview.

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishFilePreview: some View {
        ArtifactFileFicha(
            name: item.name,
            subtitle: "\(ArtifactViewer.byteLabel(item.byteSize)) · sha \(String(item.sha256.prefix(12)))"
        )
    }
}
