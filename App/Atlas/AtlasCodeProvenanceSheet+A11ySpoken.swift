import Foundation
import AtlasCore

// Sheet/header spoken — peel de AtlasCodeProvenanceSheet+A11y.

extension AtlasCodeProvenanceSheet {
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
}
