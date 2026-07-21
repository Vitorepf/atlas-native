import Foundation

// MARK: - Types

/// Exclusive trace evidence chrome face (WAVE-068).
enum TraceEvidenceFace: Equatable {
    case loading
    case unavailable

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .unavailable: return "unavailable"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading: return "consultando evidência"
        case .unavailable: return "evidência indisponível"
        }
    }
}

// MARK: - Judgment

/// Pure trace-evidence grammar — face · reason · spoken · pack.
enum TraceEvidenceJudgment {

    static func face(isLoading: Bool) -> TraceEvidenceFace {
        isLoading ? .loading : .unavailable
    }

    static func knownMissingRunReason(_ reason: String) -> String? {
        switch reason {
        case "no_workspace": return "sem workspace ligado a esta execução"
        case "no_run": return "nenhum run de engenharia vinculado"
        default: return nil
        }
    }

    static func knownUnavailableReason(_ reason: String) -> String? {
        if let missing = knownMissingRunReason(reason) { return missing }
        switch reason {
        case "multiple_runs": return "mais de um run — evidência indisponível"
        case "ambiguous_linked_runs": return "vínculo ambíguo entre runs"
        default: return nil
        }
    }

    /// Honesty: known codes → PT; else underscore→space; nil if empty.
    static func unavailableReason(_ reason: String?) -> String? {
        guard let reason, !reason.isEmpty else { return nil }
        return knownUnavailableReason(reason)
            ?? reason.replacingOccurrences(of: "_", with: " ")
    }

    static func spokenUnavailable(prefix: String, reason: String?) -> String {
        var parts = [prefix]
        if let reason = unavailableReason(reason) { parts.append(reason) }
        return parts.joined(separator: ", ")
    }

    static func spokenLoading(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? TraceEvidenceFace.loading.spokenFace : trimmed
    }

    static func packFacts(
        isLoading: Bool,
        reason: String? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(isLoading: isLoading)
        facts.append("trace_evidence_face: \(face.productWord)")
        if isLoading {
            absences.append("evidência ainda consultando")
        } else {
            absences.append("evidência indisponível neste recorte")
            if let reason, !reason.isEmpty {
                facts.append("trace_evidence_reason: \(reason)")
                if let spoken = unavailableReason(reason) {
                    facts.append("trace_evidence_reason_pt: \(spoken)")
                }
            }
        }
        return (facts, absences)
    }
}
