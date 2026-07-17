import SwiftUI
import AtlasCore

// Radar shell spoken — peel de AtlasCodeRadarView+A11y.

extension AtlasCodeRadarView {
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
