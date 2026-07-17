import SwiftUI
import AtlasCore

// Deep links `atlas://` — peel de RootView (régua <110).

extension RootView {
    func handleDeepLink(_ url: URL) {
        guard let link = AtlasDeepLink.parse(url) else { return }
        switch link {
        case .autonomos:
            path = NavigationPath()
            path.append(Route.autonomos)
        case .arena:
            path = NavigationPath()
            path.append(Route.arena)
        case .codeHome:
            path = NavigationPath()
            path.append(Route.code)
        case .code(let repo):
            path.append(Route.codeGraph(repo: repo))
        case .executionHome:
            // Widget "Seguir" sem trace: home; se há sessão viva real com
            // thread, abre a mais recente — nunca inventa conversa.
            path = NavigationPath()
            let live = (TurnPresence.shared.liveSessions + session.remoteLiveSessions)
                .sorted { $0.startedAt < $1.startedAt }
            if let snap = live.last(where: { $0.threadId != nil }),
               let threadId = snap.threadId {
                path.append(Route.thread(id: threadId, title: snap.title))
            }
        case .execution(let traceId):
            Task { @MainActor in
                guard let trace = try? await session.client.getAiInteraction(TraceID(traceId)).trace,
                      let rawThread = trace.threadId else { return }
                let threadId = ThreadID(rawThread)
                let title = session.threads.first(where: { $0.id == rawThread })?.title ?? "Execução Atlas"
                path = NavigationPath()
                path.append(Route.thread(id: threadId, title: title))
            }
        }
    }
}
