import SwiftUI
import AtlasCore

// Deep links `atlas://` — peel de RootView (régua <110).
// Execution → RootView+DeepLinksExecution.swift
// Surface → RootView+DeepLinksSurface.swift

extension RootView {
    func handleDeepLink(_ url: URL) {
        guard let link = AtlasDeepLink.parse(url) else { return }
        switch link {
        case .autonomos, .arena, .codeHome, .code(_):
            handleSurfaceDeepLink(link)
        case .executionHome:
            handleExecutionHomeDeepLink()
        case .execution(let traceId):
            handleExecutionDeepLink(traceId: traceId)
        }
    }
}
