import Foundation
import AtlasCore

/// Spoken labels — peel de ArenaCapabilitiesSection (CICLO C residual honesty).
/// Casos/suites só quando o servidor publica; gráfico decorativo.
/// Captions → ArenaCapabilitiesSection+A11yCaptions.swift
/// Row → ArenaCapabilitiesSection+A11yRow.swift
/// Lead → ArenaCapabilitiesSection+A11yLead.swift

enum ArenaCapabilitiesSectionA11y {
    static func spokenSection(_ capabilities: AtlasArenaCapabilities) -> String {
        var parts = spokenSectionLead(capabilities)
        if ArenaCapabilitiesSectionA11yCaptions.hasChartPoints(capabilities.capabilities) {
            parts.append("gráfico comparativo disponível")
        }
        return parts.joined(separator: ", ")
    }

    static func spokenCapability(_ capability: AtlasArenaCapability) -> String {
        ArenaCapabilitiesSectionA11yRow.spokenCapability(capability)
    }
}
