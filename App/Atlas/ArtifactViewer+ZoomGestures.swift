import SwiftUI
import UIKit

// Gestures — peel de ZoomableArtifactImage.
// Reset → ArtifactViewer+ZoomReset.swift
// Drag → ArtifactViewer+ZoomDrag.swift

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
}
