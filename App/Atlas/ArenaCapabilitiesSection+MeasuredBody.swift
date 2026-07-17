import SwiftUI
import AtlasCore

// Capabilities measured body — peel de ArenaCapabilitiesSection.
// Rows → ArenaCapabilitiesSection+MeasuredBody+Rows.swift
// Chart → ArenaCapabilitiesSection+MeasuredBody+Chart.swift
// CardChrome → ArenaCapabilitiesSection+MeasuredBody+CardChrome.swift

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesMeasuredBody(_ capabilities: AtlasArenaCapabilities) -> some View {
        capabilitiesMeasuredCardChrome(
            VStack(alignment: .leading, spacing: 14) {
                capabilitiesMeasuredRows(capabilities)
                capabilitiesMeasuredChart
            },
            capabilities: capabilities
        )
    }
}
