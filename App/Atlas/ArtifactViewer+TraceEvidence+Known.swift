import SwiftUI

/// Known unavailable reason copy — peel de ArtifactViewer+TraceEvidence.
/// Missing → ArtifactViewer+TraceEvidence+Known+Missing.swift

extension TraceEvidenceCopy {
    static func knownUnavailableReason(_ reason: String) -> String? {
        if let missing = knownMissingRunReason(reason) { return missing }
        switch reason {
        case "multiple_runs": return "mais de um run — evidência indisponível"
        case "ambiguous_linked_runs": return "vínculo ambíguo entre runs"
        default: return nil
        }
    }
}
