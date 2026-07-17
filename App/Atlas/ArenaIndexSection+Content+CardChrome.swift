import SwiftUI
import AtlasCore

// Index card chrome — peel de ArenaIndexSection+Content.

extension ArenaIndexSection {
    func indexContentCardChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(16)
            .atlasCard()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(sectionSpokenLabel)
            .accessibilityIdentifier(A11yID.arenaIndexSection)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: composite.engines.map(\.id))
    }
}
