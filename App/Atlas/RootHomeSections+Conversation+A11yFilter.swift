import AtlasCore
import SwiftUI

/// Active workspace filter spoken — peel de RootHomeSections+Conversation+A11y.

extension RootHomeSections {
    func activeWorkspaceFilterLabel() -> String {
        switch homeWorkspaceFilter {
        case .none: return "Livres"
        case .some("__all"): return "Todas"
        case .some(let key):
            return session.workspaces.first(where: { $0.id == key })?.name ?? "Workspace"
        }
    }
}
