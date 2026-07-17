import Foundation
import AtlasCore

// Captions casos/suites — peel de ArenaCapabilitiesSection+A11y.

enum ArenaCapabilitiesSectionA11yCaptions {
    static func casesCaption(for capability: AtlasArenaCapability) -> String? {
        guard let total = capability.casesTotal, total > 0 else { return nil }
        return "\(total) casos"
    }

    static func suitesCaption(for capability: AtlasArenaCapability) -> String? {
        guard !capability.suitesContributing.isEmpty else { return nil }
        return "suites \(capability.suitesContributing.joined(separator: ", "))"
    }

    static func hasChartPoints(_ capabilities: [AtlasArenaCapability]) -> Bool {
        capabilities.contains { $0.score != nil || $0.withAtlas != nil }
    }
}
