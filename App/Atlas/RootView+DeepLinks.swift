import SwiftUI
import AtlasCore

// Deep links `atlas://` — peel de RootView (régua <110).
// Execution → RootView+DeepLinksExecution.swift
// Surface → RootView+DeepLinksSurface.swift
// Surface peel → RootView+DeepLinks+Surface.swift
// ExecutionFamily → RootView+DeepLinks+ExecutionFamily.swift

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
