import Foundation
import AtlasCore

// Suites caption — peel de ArenaCapabilitiesSection+A11yCaptions.

extension ArenaCapabilitiesSectionA11yCaptions {
    static func suitesCaption(for capability: AtlasArenaCapability) -> String? {
        guard !capability.suitesContributing.isEmpty else { return nil }
        return "suites \(capability.suitesContributing.joined(separator: ", "))"
    }
}
