import SwiftUI
import UIKit

// Reset helpers — peel de ZoomableArtifactImage gestures.
// Clamp → ArtifactViewer+ZoomClamp.swift
// Offset → ArtifactViewer+ZoomOffset.swift
// Scale → ArtifactViewer+ZoomScale.swift

extension ZoomableArtifactImage {
    func resetZoom() {
        scale = 1
        lastScale = 1
        resetOffset()
    }
}
