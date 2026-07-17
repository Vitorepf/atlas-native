import SwiftUI
import AtlasCore

// Contagens — peel de RootHomeSections+Conversation.
// Audit → RootHomeSections+ConversationAudit.swift

extension RootHomeSections {
    var freeThreadCount: Int {
        session.threads.filter { $0.workspace == nil }.count
    }

    var homeConversationThreadCount: Int {
        switch homeWorkspaceFilter {
        case .some("__all"): return session.threads.count
        case .some(let key): return session.threads(inWorkspace: key).count
        case .none: return freeThreadCount
        }
    }

    var homeConversationCount: Int? {
        let n = homeConversationThreadCount
        return n > 0 ? n : nil
    }
}
