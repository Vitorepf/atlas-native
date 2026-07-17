import SwiftUI
import AtlasCore

// Radar loaded shell spoken — peel de AtlasCodeRadarView+A11yShell.

extension AtlasCodeRadarView {
    func radarShellLoadedParts() -> [String] {
        if let workspace = model.workspace, workspace.repositoryCount > 0 {
            let n = workspace.repositoryCount
            return ["\(n) repositório\(n == 1 ? "" : "s")"]
        }
        return [spokenEmptyWorkspace()]
    }
}
