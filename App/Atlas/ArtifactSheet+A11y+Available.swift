import Foundation
import AtlasCore

/// Artifact sheet available spoken — peel de ArtifactSheet+A11y.

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
