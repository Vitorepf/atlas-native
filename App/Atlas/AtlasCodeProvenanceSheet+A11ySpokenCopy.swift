import Foundation
import AtlasCore

// Provenance spoken helpers — peel de AtlasCodeProvenanceSheet+A11y.

extension AtlasCodeProvenanceSheet {
    func spokenLawCitation() -> String? {
        guard state == .violating, let ruleId else { return nil }
        var parts = [AtlasCodeIssue.law(ruleId, trunk: trunk)]
        if let ruleCanon = ruleCanon?.nonEmpty { parts.append(ruleCanon) }
        return parts.joined(separator: ", ")
    }

    func spokenDateline() -> String {
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        var parts = [author]
        if case .loaded(let provenance) = phase, !provenance.agent.isEmpty {
            parts.append(provenance.agentLabel)
        }
        parts.append("há \(AtlasCodeRelativeTime.short(from: node.authoredAt))")
        return parts.joined(separator: ", ")
    }

    func spokenLoading() -> String { "lendo proveniência do commit" }

    func spokenFailed(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "proveniência indisponível" }
        return "proveniência indisponível, \(trimmed)"
    }

    static let sheetHint = "estado do commit, lei aplicável e o que o ledger registrou"
    static let askHint = "abre conversa com este commit no assunto"
}
