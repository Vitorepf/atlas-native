import SwiftUI
import UIKit

// Gestures — peel de ZoomableArtifactImage.
// Reset → ArtifactViewer+ZoomReset.swift

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
}
