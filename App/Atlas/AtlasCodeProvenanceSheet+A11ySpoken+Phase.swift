import Foundation
import AtlasCore

// Provenance phase spoken — peel de AtlasCodeProvenanceSheet+A11ySpoken.
// Loaded → AtlasCodeProvenanceSheet+A11ySpoken+Phase+Loaded.swift

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
