import SwiftUI
import PhotosUI
import AtlasCore

// Model state — peel de ConversationView+Init.

extension ConversationView {
    static func initModelState(
        client: AtlasClient,
        threadId: ThreadID?,
        taskKind: String?,
        workspace: String?,
        draft: String,
        turnFacts: ((String) async -> String?)? = nil
    ) -> State<ConversationModel> {
        State(initialValue: Self.seededModel(
            client: client,
            threadId: threadId,
            taskKind: taskKind,
            workspace: workspace,
            draft: draft,
            turnFacts: turnFacts
        ))
    }
}
