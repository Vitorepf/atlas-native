import Foundation
import AtlasCore

// Image/text preview spoken — peel de ArtifactViewer+A11yPreview.

extension ArtifactViewerA11y {
    static func spokenPreviewDocument(item: AtlasTraceArtifacts.Item, size: String) -> String? {
        switch item.kind {
        case .image:
            return "preview de imagem \(item.name), \(size)"
        case .markdown:
            return "preview markdown \(item.name), \(size)"
        case .text:
            return "preview de texto \(item.name), \(size)"
        case .diff:
            return "preview de diff \(item.name), \(size)"
        default:
            return nil
        }
    }
}
