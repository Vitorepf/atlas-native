import SwiftUI
import AtlasCore

// Autonomos hub deep link — peel de RootView+DeepLinksSurface+Hub.

extension RootView {
    func handleAutonomosDeepLink() {
        path = NavigationPath()
        path.append(Route.autonomos)
    }
}
