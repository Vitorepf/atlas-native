import SwiftUI
import AtlasCore

// Autonomos/Arena/Code deep links — peel de RootView+DeepLinks.
// Hub → RootView+DeepLinksSurface+Hub.swift
// CodeGraph → RootView+DeepLinksSurface+CodeGraph.swift

extension RootView {
    func handleSurfaceDeepLink(_ link: AtlasDeepLink) {
        handleHubDeepLink(link)
        handleCodeGraphDeepLink(link)
    }
}
