import SwiftUI

/// Copy editorial para `reason` do contrato trace-scoped — nunca inventa motivo.
/// Unavailable → ArtifactViewer+TraceEvidenceUnavailable.swift
/// Loading → ArtifactViewer+TraceEvidenceLoading.swift
enum TraceEvidenceCopy {
    static func unavailableReason(_ reason: String?) -> String? {
        guard let reason, !reason.isEmpty else { return nil }
        switch reason {
        case "no_workspace": return "sem workspace ligado a esta execução"
        case "no_run": return "nenhum run de engenharia vinculado"
        case "multiple_runs": return "mais de um run — evidência indisponível"
        case "ambiguous_linked_runs": return "vínculo ambíguo entre runs"
        default:
            return reason.replacingOccurrences(of: "_", with: " ")
        }
    }

    static func unavailableSpoken(prefix: String, reason: String?) -> String {
        var parts = [prefix]
        if let reason = unavailableReason(reason) { parts.append(reason) }
        return parts.joined(separator: ", ")
    }
}
