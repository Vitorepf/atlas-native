import SwiftUI
import PhotosUI
import AtlasCore

// Workspace seed — peel de ConversationView+InitSeed.

extension ConversationView {
    static func seedWorkspace(on model: ConversationModel, workspace: String?) {
        guard let workspace else { return }
        model.workspaceSlug = workspace
        model.workspaceName = workspace
    }
}
