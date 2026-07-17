import Foundation
import AtlasCore

// Image/text preview spoken — peel de ArtifactViewer+A11yPreview.
// ImageMarkdown → ArtifactViewer+A11yPreview+Document+ImageMarkdown.swift

extension ArtifactViewerA11y {
    static func spokenPreviewDocument(item: AtlasTraceArtifacts.Item, size: String) -> String? {
        if let imageMd = spokenPreviewImageMarkdown(item: item, size: size) { return imageMd }
        switch item.kind {
        case .text:
            return "preview de texto \(item.name), \(size)"
        case .diff:
            return "preview de diff \(item.name), \(size)"
        default:
            return nil
        }
    }
}
