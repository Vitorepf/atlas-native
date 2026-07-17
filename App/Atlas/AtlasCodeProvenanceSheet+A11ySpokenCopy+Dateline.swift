import Foundation
import AtlasCore

// Dateline spoken — peel de AtlasCodeProvenanceSheet+A11ySpokenCopy.

extension AtlasCodeProvenanceSheet {
    func spokenDateline() -> String {
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        var parts = [author]
        if case .loaded(let provenance) = phase, !provenance.agent.isEmpty {
            parts.append(provenance.agentLabel)
        }
        parts.append("há \(AtlasCodeRelativeTime.short(from: node.authoredAt))")
        return parts.joined(separator: ", ")
    }
}
