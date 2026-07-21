import AtlasCore

// Image/markdown kind labels — peel de ArtifactViewer+KindLabel+Document.

extension ArtifactViewer {
    static func kindLabelImageMarkdown(_ kind: AtlasTraceArtifacts.Item.Kind) -> String? {
        switch kind {
        case .image: return "imagem"
        case .markdown: return "markdown"
        default: return nil
        }
    }
}
