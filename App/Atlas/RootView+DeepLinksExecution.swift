import SwiftUI
import AtlasCore

// Execution deep link — peel de RootView+DeepLinks.

extension RootView {
    func handleExecutionDeepLink(traceId: String) {
        Task { @MainActor in
            guard let trace = try? await session.client.getAiInteraction(TraceID(traceId)).trace,
                  let rawThread = trace.threadId else { return }
            let threadId = ThreadID(rawThread)
            let title = session.threads.first(where: { $0.id == rawThread })?.title ?? "Execução Atlas"
            path = NavigationPath()
            path.append(Route.thread(id: threadId, title: title))
        }
    }

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
