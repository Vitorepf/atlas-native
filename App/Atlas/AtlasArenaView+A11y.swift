import SwiftUI
import AtlasCore

/// Spoken labels e gates de silêncio — peel de AtlasArenaView (CICLO C residual honesty).
/// Domain/run → AtlasArenaView+DomainA11y.swift
/// Screen → AtlasArenaView+A11yScreen.swift
/// Header → AtlasArenaView+A11yHeader.swift

extension AtlasArenaView {
    var contentPhaseID: String {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .loaded: return "loaded"
        case .failed: return model.isDomainUnavailable ? "domain-unavailable" : "failed"
        }
    }
}
