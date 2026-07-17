import SwiftUI
import AtlasCore

// Execution home deep link — peel de RootView+DeepLinksExecution.

extension RootView {
    func handleExecutionHomeDeepLink() {
        // Widget "Seguir" sem trace: home; se há sessão viva real com
        // thread, abre a mais recente — nunca inventa conversa.
        path = NavigationPath()
        let live = (TurnPresence.shared.liveSessions + session.remoteLiveSessions)
            .sorted { $0.startedAt < $1.startedAt }
        if let snap = live.last(where: { $0.threadId != nil }),
           let threadId = snap.threadId {
            path.append(Route.thread(id: threadId, title: snap.title))
        }
    }
}
