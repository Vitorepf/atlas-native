import AtlasCore
import Foundation

// Cycle 033 fuse → ArtifactViewer+A11y.swift

/// Sem inventar dimensões; sha só quando o contrato publica.

enum ArtifactViewerA11y {
    static func spokenFicha(name: String, subtitle: String) -> String {
        "\(name), \(subtitle)"
    }
}

extension ArtifactViewerA11y {
    static func spokenDecodeFailure(name: String, bytes: Int) -> String {
        "imagem \(name) não pôde ser decodificada, \(ArtifactViewer.byteLabel(bytes))"
    }
}

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

extension ArtifactViewerA11y {
    static func spokenPreviewFile(item: AtlasTraceArtifacts.Item, kind: String, size: String) -> String {
        let sha = String(item.sha256.prefix(12))
        return "arquivo \(item.name), \(kind), \(size), sha \(sha)"
    }
}

extension ArtifactViewerA11y {
    static func spokenPreview(item: AtlasTraceArtifacts.Item) -> String {
        let kind = ArtifactViewer.kindLabel(item.kind)
        let size = ArtifactViewer.byteLabel(item.byteSize)
        return spokenPreviewDocument(item: item, size: size)
            ?? spokenPreviewFile(item: item, kind: kind, size: size)
    }
}

extension ArtifactViewerA11y {
    static func spokenTooLarge(name: String, bytes: Int) -> String {
        "\(name), grande demais para visualizar aqui, \(ArtifactViewer.byteLabel(bytes))"
    }
}
