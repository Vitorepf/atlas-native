import Foundation
import AtlasCore

// Preview spoken — peel de ArtifactViewer+A11y.
// Document → ArtifactViewer+A11yPreview+Document.swift
// File → ArtifactViewer+A11yPreview+File.swift

extension ArtifactViewerA11y {
    static func spokenPreview(item: AtlasTraceArtifacts.Item) -> String {
        let kind = ArtifactViewer.kindLabel(item.kind)
        let size = ArtifactViewer.byteLabel(item.byteSize)
        return spokenPreviewDocument(item: item, size: size)
            ?? spokenPreviewFile(item: item, kind: kind, size: size)
    }
}
