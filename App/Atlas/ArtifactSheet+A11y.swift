import AtlasCore
import Foundation

// Cycle 027 fuse → ArtifactSheet+A11y.swift

extension ArtifactSheet {
    func spokenArtifactsSheetAvailableLabel(_ artifacts: AtlasTraceArtifacts) -> String {
        switch artifacts.state {
        case .unavailable:
            return "artefatos da execução indisponíveis"
        case .available:
            let n = items.count
            if n == 0 { return "artefatos da execução, sem itens publicados" }
            return "artefatos da execução, \(n) item\(n == 1 ? "" : "s")"
        }
    }
}

extension ArtifactSheet {
    func spokenArtifactsSheetLoadLabel() -> String? {
        if !loadFinished, artifacts == nil {
            return "artefatos da execução, consultando"
        }
        if loadFinished, artifacts == nil {
            return "artefatos da execução, indisponível"
        }
        return nil
    }
}

extension ArtifactSheet {
    func spokenArtifactsSheetLabel() -> String {
        if let load = spokenArtifactsSheetLoadLabel() { return load }
        guard let artifacts else { return "artefatos da execução" }
        return spokenArtifactsSheetAvailableLabel(artifacts)
    }
}
