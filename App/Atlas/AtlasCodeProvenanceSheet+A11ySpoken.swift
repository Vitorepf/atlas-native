import AtlasCore
import Foundation

// Cycle 039 fuse → AtlasCodeProvenanceSheet+A11ySpoken.swift

extension AtlasCodeProvenanceSheet {
    func provenanceSheetLoadedParts(_ provenance: AtlasCodeProvenance) -> [String] {
        if let headline = provenance.diffHeadline { return [headline] }
        if !hasLoadedBody(provenance) { return ["ledger sem detalhe neste recorte"] }
        return []
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceSheetPhaseParts() -> [String] {
        switch phase {
        case .idle, .loading:
            return [spokenLoading()]
        case .failed(let message):
            return [spokenFailed(message)]
        case .loaded(let provenance):
            return provenanceSheetLoadedParts(provenance)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceSheetSpokenLabel: String {
        var parts = ["proveniência do commit", spokenHeaderTitle(), spokenStateKicker()]
        parts.append(contentsOf: provenanceSheetPhaseParts())
        return parts.joined(separator: ", ")
    }
}
