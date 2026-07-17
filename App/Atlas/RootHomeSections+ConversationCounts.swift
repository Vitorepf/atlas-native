import SwiftUI
import AtlasCore

// Contagens — peel de RootHomeSections+Conversation.
// Audit → RootHomeSections+ConversationAudit.swift
// Free → RootHomeSections+ConversationFree.swift
// Optional → RootHomeSections+ConversationOptional.swift
// Workspace → RootHomeSections+ConversationCounts+Workspace.swift

extension RootHomeSections {
    var homeConversationThreadCount: Int {
        homeConversationWorkspaceCount ?? freeThreadCount
    }
}
