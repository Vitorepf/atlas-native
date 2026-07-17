import SwiftUI
import AtlasCore

// Hub deep links — peel de RootView+DeepLinksSurface.

extension RootView {
    func handleHubDeepLink(_ link: AtlasDeepLink) {
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
        default:
            break
        }
    }
}
