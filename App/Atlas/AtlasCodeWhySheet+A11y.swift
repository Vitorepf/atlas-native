import Foundation
import AtlasCore

/// Spoken labels — peel de AtlasCodeWhySheet (CICLO C residual honesty).
/// Commit → AtlasCodeWhySheet+A11yCommit.swift
/// Spoken → AtlasCodeWhySheet+A11ySpoken.swift
/// Labels → AtlasCodeWhySheet+A11yLabels.swift

extension AtlasCodeWhySheet {
    var whyContentPhaseID: String {
        switch model.phase {
        case .idle, .loading: return "loading"
        case .failed: return "failed"
        case .loaded:
            guard let why = model.why else { return "loaded-nil" }
            return why.commits.isEmpty ? "empty" : "timeline-\(why.commits.count)"
        }
    }
}
