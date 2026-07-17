import SwiftUI
import AtlasCore

// Badge remota — peel de LiveNowRow+Content.
// Capsule → LiveNowRow+RemoteBadge+Capsule.swift

extension LiveNowRow {
    var remoteBadge: some View {
        remoteBadgeCapsule
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("sessão remota em outra superfície")
            .accessibilityIdentifier(remoteBadgeID ?? "")
    }
}
