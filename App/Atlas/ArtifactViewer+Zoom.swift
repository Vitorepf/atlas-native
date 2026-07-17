import SwiftUI
import UIKit

struct ZoomableArtifactImage: View {
    let image: UIImage
    let name: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
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
            .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: scale)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: offset)
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = clamped(lastScale * value)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1 { resetOffset() }
            }
    }

    private var dragGesture: some Gesture {
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

    private func setScale(_ value: CGFloat) {
        scale = clamped(value)
        lastScale = scale
        if scale <= 1 { resetOffset() }
    }

    private func resetZoom() {
        scale = 1
        lastScale = 1
        resetOffset()
    }

    private func resetOffset() {
        offset = .zero
        lastOffset = .zero
    }

    private func clamped(_ value: CGFloat) -> CGFloat {
        min(4, max(1, value))
    }
}
