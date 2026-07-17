import Foundation
import AtlasCore

// Sheet spoken — peel de AtlasCodeProvenanceSheet+A11y.
// Kickers → AtlasCodeProvenanceSheet+A11yKickers.swift

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
}
