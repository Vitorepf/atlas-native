import SwiftUI
import AtlasCore

// Deep links `atlas://` — peel de RootView (régua <110).
// Execution → RootView+DeepLinksExecution.swift

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
            handleExecutionHomeDeepLink()
        case .execution(let traceId):
            handleExecutionDeepLink(traceId: traceId)
        }
    }
}
