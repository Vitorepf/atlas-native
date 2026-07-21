import SwiftUI
import AtlasCore

// IDLE-COMPRESS peel Root deep-link handlers (canon §7 · same domain)

extension RootView {
    func handleExecutionFamilyDeepLink(_ link: AtlasDeepLink) {
        switch link {
        case .executionHome:
            handleExecutionHomeDeepLink()
        case .execution(let traceId):
            handleExecutionDeepLink(traceId: traceId)
        default:
            break
        }
    }
}

extension RootView {
    func handleSurfaceOrCodeDeepLink(_ link: AtlasDeepLink) {
        switch link {
        case .autonomos, .arena, .codeHome, .code(_):
            handleSurfaceDeepLink(link)
        default:
            break
        }
    }
}

extension RootView {
    func handleDeepLink(_ url: URL) {
        guard let link = AtlasDeepLink.parse(url) else { return }
        switch link {
        case .autonomos, .arena, .codeHome, .code(_):
            handleSurfaceOrCodeDeepLink(link)
        case .executionHome, .execution(_):
            handleExecutionFamilyDeepLink(link)
        }
    }
}

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
}

extension RootView {
    func handleCodeGraphDeepLink(_ link: AtlasDeepLink) {
        if case .code(let repo) = link {
            path.append(Route.codeGraph(repo: repo))
        }
    }
}

extension RootView {
    func handleArenaOrCodeDeepLink(_ link: AtlasDeepLink) {
        switch link {
        case .arena:
            path = NavigationPath()
            path.append(Route.arena)
        case .codeHome:
            path = NavigationPath()
            path.append(Route.code)
        default:
            break
        }
    }
}

extension RootView {
    func handleAutonomosDeepLink() {
        path = NavigationPath()
        path.append(Route.autonomos)
    }
}

extension RootView {
    func handleHubDeepLink(_ link: AtlasDeepLink) {
        switch link {
        case .autonomos:
            handleAutonomosDeepLink()
        case .arena, .codeHome:
            handleArenaOrCodeDeepLink(link)
        default:
            break
        }
    }
}

extension RootView {
    func handleSurfaceDeepLink(_ link: AtlasDeepLink) {
        handleHubDeepLink(link)
        handleCodeGraphDeepLink(link)
    }
}
