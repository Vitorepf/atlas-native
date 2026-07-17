import SwiftUI
import AtlasCore

// Measured rows frame — peel de ArenaCapabilitiesSection+MeasuredBody+Stack.
// Chart → ArenaCapabilitiesSection+MeasuredBody+Stack+Chart.swift

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesMeasuredRowsFrame(_ capabilities: AtlasArenaCapabilities) -> some View {
        capabilitiesMeasuredRows(capabilities)
    }
}
