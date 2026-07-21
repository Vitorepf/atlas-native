import AtlasCore

// Document kind labels — peel de ArtifactViewer+KindLabel.
// ImageMarkdown → ArtifactViewer+KindLabel+Document+ImageMarkdown.swift

extension ArtifactViewer {
    static func kindLabelDocument(_ kind: AtlasTraceArtifacts.Item.Kind) -> String? {
        if let imageMd = kindLabelImageMarkdown(kind) { return imageMd }
        switch kind {
        case .text: return "texto"
        case .diff: return "diff"
        default: return nil
        }
    }
}
