import Foundation
import AtlasCore

// Provenance phase spoken — peel de AtlasCodeProvenanceSheet+A11ySpoken.

extension AtlasCodeProvenanceSheet {
    func provenanceSheetPhaseParts() -> [String] {
        switch phase {
        case .idle, .loading:
            return [spokenLoading()]
        case .failed(let message):
            return [spokenFailed(message)]
        case .loaded(let provenance):
            if let headline = provenance.diffHeadline { return [headline] }
            if !hasLoadedBody(provenance) { return ["ledger sem detalhe neste recorte"] }
            return []
        }
    }
}
