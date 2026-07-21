import SwiftUI
import UIKit

// setScale — peel de ArtifactViewer+ZoomReset.

extension ZoomableArtifactImage {
    func setScale(_ value: CGFloat) {
        scale = clamped(value)
        lastScale = scale
        if scale <= 1 { resetOffset() }
    }
}
