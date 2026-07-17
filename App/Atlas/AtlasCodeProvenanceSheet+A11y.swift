import Foundation
import AtlasCore

/// Spoken labels — peel de AtlasCodeProvenanceSheet (CICLO C residual honesty).
/// Só fala payload real do ledger; ausência não inventa citação, arquivo nem frase.

extension AtlasCodeProvenanceSheet {
    var provenanceContentPhaseID: String {
        switch phase {
        case .idle, .loading: return "loading"
        case .failed: return "failed"
        case .loaded(let provenance):
            return hasLoadedBody(provenance) ? "loaded-\(provenance.files.count)" : "loaded-empty"
        }
    }

    func hasLoadedBody(_ provenance: AtlasCodeProvenance) -> Bool {
        provenance.commitBody?.nonEmpty != nil
            || provenance.operatorQuote?.nonEmpty != nil
            || !(provenance.gates?.isEmpty ?? true)
            || !(provenance.obra?.isEmpty ?? true)
            || !provenance.files.isEmpty
    }

    var provenanceSheetSpokenLabel: String {
        var parts = ["proveniência do commit", spokenHeaderTitle(), spokenStateKicker()]
        switch phase {
        case .idle, .loading:
            parts.append(spokenLoading())
        case .failed(let message):
            parts.append(spokenFailed(message))
        case .loaded(let provenance):
            if let headline = provenance.diffHeadline { parts.append(headline) }
            else if !hasLoadedBody(provenance) { parts.append("ledger sem detalhe neste recorte") }
        }
        return parts.joined(separator: ", ")
    }

    func spokenHeaderTitle() -> String {
        node.message?.nonEmpty ?? String(node.hash.prefix(8))
    }

    func spokenStateKicker() -> String {
        switch state {
        case .onMain: return "na \(trunk?.nonEmpty ?? "main")"
        case .violating: return "fora da \(trunk?.nonEmpty ?? "main")"
        case .healed: return "curado"
        case .history: return "história"
        }
    }

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
