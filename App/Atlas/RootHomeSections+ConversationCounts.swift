import SwiftUI
import AtlasCore

// Contagens — peel de RootHomeSections+Conversation.
// Audit → RootHomeSections+ConversationAudit.swift
// Free → RootHomeSections+ConversationFree.swift
// Optional → RootHomeSections+ConversationOptional.swift

extension RootHomeSections {
    var homeConversationThreadCount: Int {
        switch homeWorkspaceFilter {
        case .some("__all"): return session.threads.count
        case .some(let key): return session.threads(inWorkspace: key).count
        case .none: return freeThreadCount
        }
    }
}
