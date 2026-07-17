import Foundation
import AtlasCore

// Chart points predicate — peel de ArenaCapabilitiesSection+A11yCaptions.

extension ArenaCapabilitiesSectionA11yCaptions {
    static func hasChartPoints(_ capabilities: [AtlasArenaCapability]) -> Bool {
        capabilities.contains { $0.score != nil || $0.withAtlas != nil }
    }
}
