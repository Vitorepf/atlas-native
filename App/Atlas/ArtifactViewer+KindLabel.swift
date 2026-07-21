import AtlasCore

// Kind label — peel de ArtifactViewer.
// Document → ArtifactViewer+KindLabel+Document.swift

extension ArtifactViewer {
    static func kindLabel(_ kind: AtlasTraceArtifacts.Item.Kind) -> String {
        kindLabelDocument(kind) ?? "arquivo"
    }
}
