import SwiftUI
import AtlasCore

// Capability rows — peel de ArenaCapabilitiesSection+MeasuredBody.

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesMeasuredRows(_ capabilities: AtlasArenaCapabilities) -> some View {
        capabilitiesHeader(capabilities)
        engineChips
        ForEach(measuredCapabilities) { capability in
            ArenaCapabilityRow(capability: capability)
                .transition(reduceMotion ? .identity : .opacity)
        }
    }
}
