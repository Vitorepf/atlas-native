import SwiftUI
import AtlasCore

// Hub deep links — peel de RootView+DeepLinksSurface.
// Autonomos → RootView+DeepLinksSurface+Hub+Autonomos.swift
// ArenaCode → RootView+DeepLinksSurface+Hub+ArenaCode.swift

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
