import SwiftUI
import PhotosUI
import AtlasCore

// Conversation init model seed — peel de ConversationView+Init.

extension ConversationView {
    static func seededModel(
        client: AtlasClient,
        threadId: ThreadID?,
        taskKind: String?,
        workspace: String?,
        draft: String,
        turnFacts: ((String) async -> String?)?
    ) -> ConversationModel {
        let model = ConversationModel(client: client, threadId: threadId)
        model.turnFacts = turnFacts
        model.taskKind = taskKind
        if let workspace {
            model.workspaceSlug = workspace
            model.workspaceName = workspace
        }
        if !draft.isEmpty {
            model.updateDraft(draft)
        }
        return model
    }
}
