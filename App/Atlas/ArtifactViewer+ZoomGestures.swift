import SwiftUI
import UIKit

// Gestures + reset — peel de ZoomableArtifactImage.

extension ZoomableArtifactImage {
    var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = clamped(lastScale * value)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1 { resetOffset() }
            }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

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
