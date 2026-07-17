import Foundation
import AtlasCore

/// Spoken sheet label — peel de ArtifactSheet (CICLO C residual honesty).

extension ArtifactSheet {
    func spokenArtifactsSheetLabel() -> String {
        if !loadFinished, artifacts == nil {
            return "artefatos da execução, consultando"
        }
        if loadFinished, artifacts == nil {
            return "artefatos da execução, indisponível"
        }
        guard let artifacts else { return "artefatos da execução" }
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
