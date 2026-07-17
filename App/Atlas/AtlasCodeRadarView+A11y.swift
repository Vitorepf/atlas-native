import SwiftUI
import AtlasCore

/// Spoken labels — peel de AtlasCodeRadarView (CICLO C residual honesty).
/// Shell fala só fase real e contagens do payload; ausência não inventa repositórios.
/// Spoken helpers → AtlasCodeRadarView+A11ySpoken.swift

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

    var radarShellSpokenLabel: String {
        var parts = ["Código, workspace do operador"]
        switch model.phase {
        case .idle, .loading:
            parts.append(spokenLoading())
        case .failed(let message):
            parts.append(spokenFailed(message))
        case .loaded:
            if let workspace = model.workspace, workspace.repositoryCount > 0 {
                let n = workspace.repositoryCount
                parts.append("\(n) repositório\(n == 1 ? "" : "s")")
            } else {
                parts.append(spokenEmptyWorkspace())
            }
        }
        return parts.joined(separator: ", ")
    }
}
