import Foundation
import AtlasCore

/// Capability row spoken — peel de ArenaCapabilitiesSection+A11y.

enum ArenaCapabilitiesSectionA11yRow {
    static func spokenCapability(_ capability: AtlasArenaCapability) -> String {
        var parts = [
            capability.labelPt,
            "score \(ArenaFormat.score(capability.score))",
            "com Atlas \(ArenaFormat.score(capability.withAtlas))",
        ]
        if let cases = ArenaCapabilitiesSectionA11yCaptions.casesCaption(for: capability) { parts.append(cases) }
        if let suites = ArenaCapabilitiesSectionA11yCaptions.suitesCaption(for: capability) { parts.append(suites) }
        return parts.joined(separator: ", ")
    }
}
