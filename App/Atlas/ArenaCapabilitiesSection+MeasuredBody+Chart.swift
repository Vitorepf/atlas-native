import SwiftUI
import AtlasCore

// Chart block — peel de ArenaCapabilitiesSection+MeasuredBody.

extension ArenaCapabilitiesSection {
    var capabilitiesMeasuredChart: some View {
        ArenaCapabilitiesChart(capabilities: measuredCapabilities)
            .frame(height: 190)
    }
}
