import Foundation
import AtlasCore

/// Spoken labels do preview de artefato — peel de ArtifactViewer (CICLO C).
/// Sem inventar dimensões; sha só quando o contrato publica.

enum ArtifactViewerA11y {
    static func spokenFicha(name: String, subtitle: String) -> String {
        "\(name), \(subtitle)"
    }

    static func spokenPreview(item: AtlasTraceArtifacts.Item) -> String {
        let kind = ArtifactViewer.kindLabel(item.kind)
        let size = ArtifactViewer.byteLabel(item.byteSize)
        switch item.kind {
        case .image:
            return "preview de imagem \(item.name), \(size)"
        case .markdown:
            return "preview markdown \(item.name), \(size)"
        case .text:
            return "preview de texto \(item.name), \(size)"
        case .diff:
            return "preview de diff \(item.name), \(size)"
        case .file:
            let sha = String(item.sha256.prefix(12))
            return "arquivo \(item.name), \(kind), \(size), sha \(sha)"
        }
    }

    static func spokenDecodeFailure(name: String, bytes: Int) -> String {
        "imagem \(name) não pôde ser decodificada, \(ArtifactViewer.byteLabel(bytes))"
    }

    static func spokenTooLarge(name: String, bytes: Int) -> String {
        "\(name), grande demais para visualizar aqui, \(ArtifactViewer.byteLabel(bytes))"
    }
}
