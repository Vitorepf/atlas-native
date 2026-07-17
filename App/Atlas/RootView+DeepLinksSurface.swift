import SwiftUI
import AtlasCore

// Autonomos/Arena/Code deep links — peel de RootView+DeepLinks.

extension RootView {
    func handleSurfaceDeepLink(_ link: AtlasDeepLink) {
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
        case .executionHome, .execution:
            break
        }
    }
}
