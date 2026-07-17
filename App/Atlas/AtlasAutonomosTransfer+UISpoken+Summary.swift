import AtlasCore

// Spoken summary — peel de AtlasAutonomosTransfer+UISpoken.
// Hosts → AtlasAutonomosTransfer+UISpoken+Summary+Hosts.swift

extension AtlasAutonomosTransferResponse {
    var transferSpokenSummary: String {
        var parts = ["transferência", handoff.status, "foco \(handoff.focus)"]
        parts.append(contentsOf: transferSpokenHostParts)
        if !transferMilestoneTags.isEmpty { parts.append(transferMilestoneTags.joined(separator: ", ")) }
        if let note = note?.nonEmpty { parts.append(note) }
        return parts.joined(separator: ", ")
    }
}
