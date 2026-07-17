import Foundation
import AtlasCore

// Cases caption — peel de ArenaCapabilitiesSection+A11yCaptions.

extension ArenaCapabilitiesSectionA11yCaptions {
    static func casesCaption(for capability: AtlasArenaCapability) -> String? {
        guard let total = capability.casesTotal, total > 0 else { return nil }
        return "\(total) casos"
    }
}
