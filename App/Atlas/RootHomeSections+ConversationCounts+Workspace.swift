import SwiftUI
import AtlasCore

// Workspace-scoped thread count — peel de RootHomeSections+ConversationCounts.

extension RootHomeSections {
    var homeConversationWorkspaceCount: Int? {
        switch homeWorkspaceFilter {
        case .some("__all"): return session.threads.count
        case .some(let key): return session.threads(inWorkspace: key).count
        case .none: return nil
        }
    }
}
