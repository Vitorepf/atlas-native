import SwiftUI
import AtlasCore

// Capabilities measured body — peel de ArenaCapabilitiesSection.

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesMeasuredBody(_ capabilities: AtlasArenaCapabilities) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            capabilitiesHeader(capabilities)

            ForEach(measuredCapabilities) { capability in
                ArenaCapabilityRow(capability: capability)
                    .transition(reduceMotion ? .identity : .opacity)
            }
            ArenaCapabilitiesChart(capabilities: measuredCapabilities)
                .frame(height: 190)
        }
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ArenaCapabilitiesSectionA11y.spokenSection(capabilities))
        .accessibilityIdentifier(A11yID.arenaCapabilitiesSection)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: measuredCapabilities.map(\.id))
    }
}
