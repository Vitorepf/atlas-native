import SwiftUI
import AtlasCore

/// Radar phase id loaded — peel de AtlasCodeRadarView+A11y.

extension AtlasCodeRadarView {
    var contentPhaseLoadedID: String {
        guard let workspace = model.workspace else { return "loaded-nil" }
        if workspace.repositoryCount == 0 { return "loaded-empty" }
        return "loaded-\(workspace.repositoryCount)"
    }
}
