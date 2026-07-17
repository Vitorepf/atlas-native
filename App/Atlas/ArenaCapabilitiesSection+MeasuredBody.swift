import SwiftUI
import AtlasCore

// Capabilities measured body — peel de ArenaCapabilitiesSection.
// Rows → ArenaCapabilitiesSection+MeasuredBody+Rows.swift
// Chart → ArenaCapabilitiesSection+MeasuredBody+Chart.swift

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesMeasuredBody(_ capabilities: AtlasArenaCapabilities) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            capabilitiesMeasuredRows(capabilities)
            capabilitiesMeasuredChart
        }
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ArenaCapabilitiesSectionA11y.spokenSection(capabilities))
        .accessibilityIdentifier(A11yID.arenaCapabilitiesSection)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: measuredCapabilities.map(\.id))
    }
}
