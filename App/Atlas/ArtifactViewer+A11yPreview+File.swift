import Foundation
import AtlasCore

// File preview spoken — peel de ArtifactViewer+A11yPreview.

extension ArtifactViewerA11y {
    static func spokenPreviewFile(item: AtlasTraceArtifacts.Item, kind: String, size: String) -> String {
        let sha = String(item.sha256.prefix(12))
        return "arquivo \(item.name), \(kind), \(size), sha \(sha)"
    }
}
