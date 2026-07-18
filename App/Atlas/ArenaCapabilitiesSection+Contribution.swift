import SwiftUI
import AtlasCore

// Contribution line — peel de ArenaCapabilityRow.

extension ArenaCapabilityRow {
    var contributionLine: String {
        var parts: [String] = []
        if let cases = ArenaCapabilitiesSectionA11yCaptions.casesCaption(for: capability) {
            parts.append(cases)
        }
        if !capability.suitesContributing.isEmpty {
            parts.append(capability.suitesContributing.map(ArenaDisplay.suite).joined(separator: ", "))
        }
        return parts.joined(separator: " · ")
    }
}
