import SwiftUI
import AtlasCore

// Header capacidades — peel de ArenaCapabilitiesSection.
// Mapping → ArenaCapabilitiesSection+HeaderMapping.swift

extension ArenaCapabilitiesSection {
    func capabilitiesHeader(_ capabilities: AtlasArenaCapabilities) -> some View {
        HStack {
            capabilitiesTitleColumn(capabilities)
            Spacer()
            capabilitiesMapping(capabilities)
        }
    }
}
