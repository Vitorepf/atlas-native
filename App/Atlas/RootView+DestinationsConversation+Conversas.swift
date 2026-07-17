import SwiftUI
import AtlasCore

// Conversas destination — peel de RootView+DestinationsConversation.

extension RootView {
    @ViewBuilder
    var rootConversationConversasDestination: some View {
        WorkspaceView(workspaceKey: nil, title: "Conversas", freeOnly: true)
    }
}
