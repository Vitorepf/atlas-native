import SwiftUI

/// Copy editorial para `reason` do contrato trace-scoped — nunca inventa motivo.
/// Unavailable → ArtifactViewer+TraceEvidenceUnavailable.swift
/// Loading → ArtifactViewer+TraceEvidenceLoading.swift
/// Known → ArtifactViewer+TraceEvidence+Known.swift
enum TraceEvidenceCopy {
    static func unavailableReason(_ reason: String?) -> String? {
        guard let reason, !reason.isEmpty else { return nil }
        return knownUnavailableReason(reason)
            ?? reason.replacingOccurrences(of: "_", with: " ")
    }

    static func unavailableSpoken(prefix: String, reason: String?) -> String {
        var parts = [prefix]
        if let reason = unavailableReason(reason) { parts.append(reason) }
        return parts.joined(separator: ", ")
    }
}
