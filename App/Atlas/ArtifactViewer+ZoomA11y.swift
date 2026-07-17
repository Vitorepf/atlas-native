import SwiftUI
import UIKit

// Zoom a11y actions — peel de ArtifactViewer+Zoom.

extension ZoomableArtifactImage {
    func applyZoomAccessibility<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(ArtifactViewerZoomA11y.spokenImage(name: name, scale: scale))
            .accessibilityHint(ArtifactViewerZoomA11y.zoomHint)
            .accessibilityIdentifier(A11yID.artifactsZoomImage)
            .accessibilityZoomAction { action in
                switch action.direction {
                case .zoomIn:
                    setScale(scale + 0.5)
                case .zoomOut:
                    setScale(scale - 0.5)
                @unknown default:
                    break
                }
            }
            .accessibilityAction(named: ArtifactViewerZoomA11y.resetAction) { resetZoom() }
    }
}
