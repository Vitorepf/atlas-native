import SwiftUI
import AtlasCore

// Provenance dateline — peel de AtlasCodeProvenanceHeader+Meta.
// StateLabel → AtlasCodeProvenanceHeader+Dateline+StateLabel.swift

extension AtlasCodeProvenanceSheet {
    /// Autor · agente · quando. O agente só aparece quando o ledger respondeu.
    var dateline: String {
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        var parts = [author]
        if case .loaded(let provenance) = phase, !provenance.agent.isEmpty {
            parts.append(provenance.agentLabel)
        }
        parts.append("há \(AtlasCodeRelativeTime.short(from: node.authoredAt))")
        return parts.joined(separator: " · ")
    }
}
