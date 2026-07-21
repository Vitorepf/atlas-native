import SwiftUI
import AtlasCore

// Thread destination — peel de RootView+DestinationsConversation.

extension RootView {
    @ViewBuilder
    func rootConversationThreadDestination(id: ThreadID, title: String) -> some View {
        ConversationView(client: session.client, threadId: id, title: title)
    }
}
