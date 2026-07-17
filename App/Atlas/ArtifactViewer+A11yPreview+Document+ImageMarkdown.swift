import Foundation
import AtlasCore

// Image/markdown preview spoken — peel de ArtifactViewer+A11yPreview+Document.

extension ArtifactViewerA11y {
    static func spokenPreviewImageMarkdown(item: AtlasTraceArtifacts.Item, size: String) -> String? {
        switch item.kind {
        case .image:
            return "preview de imagem \(item.name), \(size)"
        case .markdown:
            return "preview markdown \(item.name), \(size)"
        default:
            return nil
        }
    }
}
