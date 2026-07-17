import SwiftUI
import AtlasCore

// Code graph deep link — peel de RootView+DeepLinksSurface.

extension RootView {
    func handleCodeGraphDeepLink(_ link: AtlasDeepLink) {
        if case .code(let repo) = link {
            path.append(Route.codeGraph(repo: repo))
        }
    }
}
