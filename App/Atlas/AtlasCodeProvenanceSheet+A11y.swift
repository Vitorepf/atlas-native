import AtlasCore
import Foundation

// Cycle 039 fuse → AtlasCodeProvenanceSheet+A11y.swift

extension AtlasCodeProvenanceSheet {
    func hasLoadedBody(_ provenance: AtlasCodeProvenance) -> Bool {
        provenance.commitBody?.nonEmpty != nil
            || provenance.operatorQuote?.nonEmpty != nil
            || !(provenance.gates?.isEmpty ?? true)
            || !(provenance.obra?.isEmpty ?? true)
            || !provenance.files.isEmpty
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceLoadedPhaseID(_ provenance: AtlasCodeProvenance) -> String {
        hasLoadedBody(provenance) ? "loaded-\(provenance.files.count)" : "loaded-empty"
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceContentPhaseID: String {
        switch phase {
        case .idle, .loading: return "loading"
        case .failed: return "failed"
        case .loaded(let provenance):
            return provenanceLoadedPhaseID(provenance)
        }
    }
}
