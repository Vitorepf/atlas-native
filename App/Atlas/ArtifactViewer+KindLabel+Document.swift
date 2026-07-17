import AtlasCore

// Document kind labels — peel de ArtifactViewer+KindLabel.

extension ArtifactViewer {
    static func kindLabelDocument(_ kind: AtlasTraceArtifacts.Item.Kind) -> String? {
        switch kind {
        case .image: return "imagem"
        case .markdown: return "markdown"
        case .text: return "texto"
        case .diff: return "diff"
        default: return nil
        }
    }
}
