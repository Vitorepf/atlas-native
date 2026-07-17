import Foundation
import AtlasCore

/// Spoken labels — peel de AtlasCodeProvenanceSheet (CICLO C residual honesty).
/// Sheet/header spoken → AtlasCodeProvenanceSheet+A11ySpoken.swift
/// Copy helpers → AtlasCodeProvenanceSheet+A11ySpokenCopy.swift

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
}
