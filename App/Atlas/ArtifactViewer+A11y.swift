import Foundation
import AtlasCore

/// Spoken labels do preview de artefato — peel de ArtifactViewer (CICLO C).
/// Sem inventar dimensões; sha só quando o contrato publica.
/// Preview → ArtifactViewer+A11yPreview.swift

enum ArtifactViewerA11y {
    static func spokenFicha(name: String, subtitle: String) -> String {
        "\(name), \(subtitle)"
    }

    static func spokenDecodeFailure(name: String, bytes: Int) -> String {
        "imagem \(name) não pôde ser decodificada, \(ArtifactViewer.byteLabel(bytes))"
    }

    static func spokenTooLarge(name: String, bytes: Int) -> String {
        "\(name), grande demais para visualizar aqui, \(ArtifactViewer.byteLabel(bytes))"
    }
}
