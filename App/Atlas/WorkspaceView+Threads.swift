import SwiftUI
import AtlasCore

// Workspace threads filter — peel de WorkspaceView+Predicates.

extension WorkspaceView {
    var threads: [AtlasAiThread] {
        let base = freeOnly
            ? session.threads.filter { $0.workspace == nil }
            : session.threads(inWorkspace: workspaceKey)
        return area == .tudo ? base : base.filter { AtlasArea.of($0) == area }
    }
}
