import SwiftUI
import UIKit

struct ZoomableArtifactImage: View {
    let image: UIImage
    let name: String
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var scale: CGFloat = 1
    @State var lastScale: CGFloat = 1
    @State var offset: CGSize = .zero
    @State var lastOffset: CGSize = .zero

    var body: some View {
        applyZoomAccessibility(
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
        )
    }
}
