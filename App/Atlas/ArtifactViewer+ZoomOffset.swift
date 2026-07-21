import SwiftUI
import UIKit

// Offset reset — peel de ArtifactViewer+ZoomReset.

extension ZoomableArtifactImage {
    func resetOffset() {
        offset = .zero
        lastOffset = .zero
    }
}
