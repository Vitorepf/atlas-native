import SwiftUI
import AtlasCore

// Measured stack — peel de ArenaCapabilitiesSection+MeasuredBody.

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesMeasuredStack(_ capabilities: AtlasArenaCapabilities) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            capabilitiesMeasuredRows(capabilities)
            capabilitiesMeasuredChart
        }
    }
}
