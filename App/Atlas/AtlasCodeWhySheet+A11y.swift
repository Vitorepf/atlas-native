import Foundation
import AtlasCore

/// Spoken labels — peel de AtlasCodeWhySheet (CICLO C residual honesty).
/// Commit → AtlasCodeWhySheet+A11yCommit.swift
/// Spoken → AtlasCodeWhySheet+A11ySpoken.swift
/// Labels → AtlasCodeWhySheet+A11yLabels.swift
/// LoadedID → AtlasCodeWhySheet+A11y+LoadedID.swift

extension AtlasCodeWhySheet {
    var whyContentPhaseID: String {
        switch model.phase {
        case .idle, .loading: return "loading"
        case .failed: return "failed"
        case .loaded: return whyContentLoadedID
        }
    }
}
