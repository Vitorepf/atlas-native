import Foundation
import AtlasCore

/// Spoken labels — peel de AtlasCodeProvenanceSheet (CICLO C residual honesty).
/// Sheet/header spoken → AtlasCodeProvenanceSheet+A11ySpoken.swift
/// Copy helpers → AtlasCodeProvenanceSheet+A11ySpokenCopy.swift
/// LoadedBody → AtlasCodeProvenanceSheet+A11y+LoadedBody.swift
/// LoadedPhaseID → AtlasCodeProvenanceSheet+A11y+LoadedPhaseID.swift

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
