import SwiftUI
import UIKit

// Zoom image core — peel de ArtifactViewer+Zoom.

extension ZoomableArtifactImage {
    var zoomImageCore: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .offset(offset)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
            .gesture(zoomGesture.simultaneously(with: dragGesture))
            .onTapGesture(count: 2) { resetZoom() }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: scale)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: offset)
    }
}
