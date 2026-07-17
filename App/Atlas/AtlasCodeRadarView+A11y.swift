import SwiftUI
import AtlasCore

/// Spoken labels — peel de AtlasCodeRadarView (CICLO C residual honesty).
/// Shell fala só fase real e contagens do payload; ausência não inventa repositórios.
/// Spoken helpers → AtlasCodeRadarView+A11ySpoken.swift
/// Shell → AtlasCodeRadarView+A11yShell.swift

extension AtlasCodeRadarView {
    var contentPhaseID: String {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .failed: return "failed"
        case .loaded:
            guard let workspace = model.workspace else { return "loaded-nil" }
            if workspace.repositoryCount == 0 { return "loaded-empty" }
            return "loaded-\(workspace.repositoryCount)"
        }
    }
}
