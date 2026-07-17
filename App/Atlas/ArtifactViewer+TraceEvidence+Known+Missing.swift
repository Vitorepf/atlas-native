import SwiftUI

/// Missing-run reasons — peel de ArtifactViewer+TraceEvidence+Known.

extension TraceEvidenceCopy {
    static func knownMissingRunReason(_ reason: String) -> String? {
        switch reason {
        case "no_workspace": return "sem workspace ligado a esta execução"
        case "no_run": return "nenhum run de engenharia vinculado"
        default: return nil
        }
    }
}
