import SwiftUI

/// Known unavailable reason copy — peel de ArtifactViewer+TraceEvidence.

extension TraceEvidenceCopy {
    static func knownUnavailableReason(_ reason: String) -> String? {
        switch reason {
        case "no_workspace": return "sem workspace ligado a esta execução"
        case "no_run": return "nenhum run de engenharia vinculado"
        case "multiple_runs": return "mais de um run — evidência indisponível"
        case "ambiguous_linked_runs": return "vínculo ambíguo entre runs"
        default: return nil
        }
    }
}
