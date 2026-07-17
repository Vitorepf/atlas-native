import SwiftUI
import UIKit

// Reset helpers — peel de ZoomableArtifactImage gestures.

extension ZoomableArtifactImage {
    func setScale(_ value: CGFloat) {
        scale = clamped(value)
        lastScale = scale
        if scale <= 1 { resetOffset() }
    }

    func resetZoom() {
        scale = 1
        lastScale = 1
        resetOffset()
    }

    func resetOffset() {
        offset = .zero
        lastOffset = .zero
    }

    func clamped(_ value: CGFloat) -> CGFloat {
        min(4, max(1, value))
    }
}
