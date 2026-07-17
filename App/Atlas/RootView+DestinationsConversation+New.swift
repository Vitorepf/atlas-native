import SwiftUI
import AtlasCore

// New conversation destination — peel de RootView+DestinationsConversation.

extension RootView {
    @ViewBuilder
    var rootConversationNewDestination: some View {
        ConversationView(client: session.client, threadId: nil, title: "Nova conversa")
    }
}
