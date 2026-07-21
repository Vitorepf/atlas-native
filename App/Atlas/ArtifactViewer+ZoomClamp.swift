import SwiftUI
import UIKit

// Clamp helper — peel de ArtifactViewer+ZoomReset.

extension ZoomableArtifactImage {
    func clamped(_ value: CGFloat) -> CGFloat {
        min(4, max(1, value))
    }
}
