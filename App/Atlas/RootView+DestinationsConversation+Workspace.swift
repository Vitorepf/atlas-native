import SwiftUI
import AtlasCore

// Workspace destination — peel de RootView+DestinationsConversation.

extension RootView {
    @ViewBuilder
    func rootConversationWorkspaceDestination(key: String?, title: String) -> some View {
        WorkspaceView(workspaceKey: key, title: title)
    }
}
