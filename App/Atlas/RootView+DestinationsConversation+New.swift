import SwiftUI
import AtlasCore

// New conversation destination — peel de RootView+DestinationsConversation.

extension RootView {
    @ViewBuilder
    func rootConversationNewDestination(workspaceKey: String?) -> some View {
        if let workspaceKey {
            let name = session.workspaces.first(where: { $0.id == workspaceKey })?.name ?? workspaceKey
            let threadCount = session.threads(inWorkspace: workspaceKey).count
            ConversationView(
                client: session.client,
                threadId: nil,
                title: name,
                emptyPrompt: WorkspaceAskContext.invite(workspaceName: name),
                emptySuggestions: WorkspaceAskContext.emptySuggestions(
                    workspaceName: name,
                    threadCount: threadCount
                ),
                workspace: workspaceKey,
                turnFacts: { [session] _ in
                    WorkspaceAskContext.facts(session: session, workspaceKey: workspaceKey)
                }
            )
        } else {
            // Livre / hub: partida Home (não inventa workspace).
            ConversationView(
                client: session.client,
                threadId: nil,
                title: "Nova conversa",
                emptyPrompt: HomeAskContext.invite,
                emptySuggestions: HomeAskContext.emptySuggestions(
                    hasWorkspaces: !session.workspaces.isEmpty
                ),
                workspace: nil,
                turnFacts: { [session] _ in
                    HomeAskContext.facts(session: session)
                }
            )
        }
    }
}
