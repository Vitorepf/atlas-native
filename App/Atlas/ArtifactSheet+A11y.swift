import Foundation
import AtlasCore

/// Spoken sheet label — peel de ArtifactSheet (CICLO C residual honesty).
/// Load → ArtifactSheet+A11y+Load.swift
/// Available → ArtifactSheet+A11y+Available.swift

extension ArtifactSheet {
    func spokenArtifactsSheetLabel() -> String {
        if let load = spokenArtifactsSheetLoadLabel() { return load }
        guard let artifacts else { return "artefatos da execução" }
        return spokenArtifactsSheetAvailableLabel(artifacts)
    }
}
