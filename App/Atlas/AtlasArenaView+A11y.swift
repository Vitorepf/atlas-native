import SwiftUI
import AtlasCore

/// Spoken labels e gates de silêncio — peel de AtlasArenaView (CICLO C residual honesty).
/// Domain/run → AtlasArenaView+DomainA11y.swift
/// Screen → AtlasArenaView+A11yScreen.swift
/// Header → AtlasArenaView+A11yHeader.swift
/// FailedID → AtlasArenaView+A11y+FailedID.swift

extension AtlasArenaView {
    var contentPhaseID: String {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .loaded: return "loaded"
        case .failed: return contentPhaseFailedID
        }
    }
}
