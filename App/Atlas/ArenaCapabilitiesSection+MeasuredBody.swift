import SwiftUI
import AtlasCore

// Capabilities measured body — peel de ArenaCapabilitiesSection.
// Stack → ArenaCapabilitiesSection+MeasuredBody+Stack.swift

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesMeasuredBody(_ capabilities: AtlasArenaCapabilities) -> some View {
        capabilitiesMeasuredCardChrome(
            capabilitiesMeasuredStack(capabilities),
            capabilities: capabilities
        )
    }
}
