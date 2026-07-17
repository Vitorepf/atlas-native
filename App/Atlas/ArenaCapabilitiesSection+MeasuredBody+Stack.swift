import SwiftUI
import AtlasCore

// Measured stack — peel de ArenaCapabilitiesSection+MeasuredBody.
// Rows → ArenaCapabilitiesSection+MeasuredBody+Stack+Rows.swift
// Chart → ArenaCapabilitiesSection+MeasuredBody+Stack+Chart.swift

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesMeasuredStack(_ capabilities: AtlasArenaCapabilities) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            capabilitiesMeasuredRowsFrame(capabilities)
            capabilitiesMeasuredChartFrame
        }
    }
}
