import Foundation
import AtlasCore

// Capabilities section spoken lead — peel de ArenaCapabilitiesSection+A11y.

extension ArenaCapabilitiesSectionA11y {
    static func spokenSectionLead(_ capabilities: AtlasArenaCapabilities) -> [String] {
        let count = capabilities.capabilities.count
        let noun = count == 1 ? "capacidade medida" : "capacidades medidas"
        var parts = ["\(count) \(noun)"]
        if let engine = capabilities.engine?.nonEmpty {
            parts.insert("motor \(engine)", at: 0)
        }
        if let mapping = capabilities.mappingVersion.nonEmpty {
            parts.append("mapeamento \(mapping)")
        }
        return parts
    }
}
