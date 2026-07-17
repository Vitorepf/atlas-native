import AtlasCore

// Spoken summary — peel de AtlasAutonomosTransfer+UISpoken.

extension AtlasAutonomosTransferResponse {
    var transferSpokenSummary: String {
        var parts = ["transferência", handoff.status, "foco \(handoff.focus)"]
        if let host = handoff.source.host?.nonEmpty { parts.append("fonte \(host)") }
        if isTargetClaimed, let host = handoff.target.host?.nonEmpty {
            parts.append("alvo \(host)")
        } else if isHandoffInFlight {
            parts.append("alvo ainda desconhecido")
        }
        if !transferMilestoneTags.isEmpty { parts.append(transferMilestoneTags.joined(separator: ", ")) }
        if let note = note?.nonEmpty { parts.append(note) }
        return parts.joined(separator: ", ")
    }
}
