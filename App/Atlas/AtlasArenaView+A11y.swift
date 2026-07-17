import SwiftUI
import AtlasCore

/// Spoken labels e gates de silêncio — peel de AtlasArenaView (CICLO C residual honesty).
/// Domain/run → AtlasArenaView+DomainA11y.swift
/// Screen → AtlasArenaView+A11yScreen.swift

extension AtlasArenaView {
    var contentPhaseID: String {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .loaded: return "loaded"
        case .failed: return model.isDomainUnavailable ? "domain-unavailable" : "failed"
        }
    }

    var headerSpokenLabel: String {
        var parts = ["Arena, medição dos motores"]
        if let regression = model.regressionException {
            parts.append(regression)
        } else if model.isDomainUnavailable, model.composite == nil {
            parts.append(ArenaModel.domainUnavailableCopy)
        }
        if let age = model.snapshotAgeText, model.composite != nil {
            parts.append("snapshot \(age)")
        }
        return parts.joined(separator: ", ")
    }
}
