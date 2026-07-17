import Foundation
import AtlasCore

// Preview spoken — peel de ArtifactViewer+A11y.

extension ArtifactViewerA11y {
    static func spokenPreview(item: AtlasTraceArtifacts.Item) -> String {
        let kind = ArtifactViewer.kindLabel(item.kind)
        let size = ArtifactViewer.byteLabel(item.byteSize)
        switch item.kind {
        case .image:
            return "preview de imagem \(item.name), \(size)"
        case .markdown:
            return "preview markdown \(item.name), \(size)"
        case .text:
            return "preview de texto \(item.name), \(size)"
        case .diff:
            return "preview de diff \(item.name), \(size)"
        case .file:
            let sha = String(item.sha256.prefix(12))
            return "arquivo \(item.name), \(kind), \(size), sha \(sha)"
        }
    }
}
