import SwiftUI
import UIKit
import AtlasCore

// Preview + zoom helpers do ArtifactSheet — fora do shell para a régua (~200).

enum ArtifactViewer {
    static func kindLabel(_ kind: AtlasTraceArtifacts.Item.Kind) -> String {
        switch kind {
        case .image: "imagem"
        case .markdown: "markdown"
        case .text: "texto"
        case .diff: "diff"
        case .file: "arquivo"
        }
    }

    static func byteLabel(_ bytes: Int) -> String {
        if bytes < 1_024 { return "\(bytes) B" }
        if bytes < 1_048_576 { return "\(max(1, bytes / 1_024)) KB" }
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.1f MB", mb).replacingOccurrences(of: ".", with: ",")
    }
}

struct ArtifactFileFicha: View {
    let name: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(AtlasFont.serif(17, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(subtitle)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ArtifactPreviewContent: View {
    let item: AtlasTraceArtifacts.Item
    let content: AtlasArtifactContent

    var body: some View {
        switch item.kind {
        case .image:
            if let image = UIImage(data: content.data) {
                ZoomableArtifactImage(image: image, name: item.name)
            } else {
                ArtifactFileFicha(
                    name: item.name,
                    subtitle: "imagem não pôde ser decodificada · \(ArtifactViewer.byteLabel(item.byteSize))"
                )
            }
        case .markdown, .text:
            AtlasMarkdownView(text: String(decoding: content.data, as: UTF8.self), streaming: false)
        case .diff:
            ScrollView(.horizontal, showsIndicators: false) {
                Text(String(decoding: content.data, as: UTF8.self))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: 360)
        case .file:
            ArtifactFileFicha(
                name: item.name,
                subtitle: "\(ArtifactViewer.byteLabel(item.byteSize)) · sha \(String(item.sha256.prefix(12)))"
            )
        }
    }
}

struct ZoomableArtifactImage: View {
    let image: UIImage
    let name: String
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
            .accessibilityLabel("imagem \(name)")
            .accessibilityHint("pinça para aproximar, arraste quando ampliada, toque duas vezes para redefinir")
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
            .accessibilityAction(named: "Redefinir zoom") { resetZoom() }
            .animation(.easeOut(duration: 0.18), value: scale)
            .animation(.easeOut(duration: 0.18), value: offset)
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
