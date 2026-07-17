import Foundation
import AtlasCore

/// Spoken labels do preview de artefato — peel de ArtifactViewer (CICLO C).
/// Sem inventar dimensões; sha só quando o contrato publica.
/// Preview → ArtifactViewer+A11yPreview.swift
/// DecodeFailure → ArtifactViewer+A11yDecodeFailure.swift · TooLarge → +A11yTooLarge

enum ArtifactViewerA11y {
    static func spokenFicha(name: String, subtitle: String) -> String {
        "\(name), \(subtitle)"
    }
}
