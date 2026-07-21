import SwiftUI
import AtlasCore

// New conversation destination — peel de RootView+DestinationsConversation.

extension RootView {
    @ViewBuilder
    func rootConversationNewDestination(workspaceKey: String?) -> some View {
        ConversationView(
            client: session.client,
            threadId: nil,
            title: workspaceKey.map { key in
                session.workspaces.first(where: { $0.id == key })?.name ?? key
            } ?? "Nova conversa",
            emptyPrompt: HomeAskContext.invite,
            emptySuggestions: HomeAskContext.emptySuggestions(
                hasWorkspaces: !session.workspaces.isEmpty
            ),
            workspace: workspaceKey,
            turnFacts: { [session] _ in
                HomeAskContext.facts(session: session)
            }
        )
    }
}
