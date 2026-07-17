import SwiftUI
import AtlasCore

// Card chrome — peel de ArenaCapabilitiesSection+MeasuredBody.

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesMeasuredCardChrome<Content: View>(
        _ content: Content,
        capabilities: AtlasArenaCapabilities
    ) -> some View {
        content
            .padding(16)
            .atlasCard()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ArenaCapabilitiesSectionA11y.spokenSection(capabilities))
            .accessibilityIdentifier(A11yID.arenaCapabilitiesSection)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: measuredCapabilities.map(\.id))
    }
}
