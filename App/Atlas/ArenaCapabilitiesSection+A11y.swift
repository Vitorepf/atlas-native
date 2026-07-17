import Foundation
import AtlasCore

/// Spoken labels — peel de ArenaCapabilitiesSection (CICLO C residual honesty).
/// Casos/suites só quando o servidor publica; gráfico decorativo.
/// Captions → ArenaCapabilitiesSection+A11yCaptions.swift

enum ArenaCapabilitiesSectionA11y {
    static func spokenSection(_ capabilities: AtlasArenaCapabilities) -> String {
        let count = capabilities.capabilities.count
        let noun = count == 1 ? "capacidade medida" : "capacidades medidas"
        var parts = ["\(count) \(noun)"]
        if let engine = capabilities.engine?.nonEmpty {
            parts.insert("motor \(engine)", at: 0)
        }
        if let mapping = capabilities.mappingVersion.nonEmpty {
            parts.append("mapeamento \(mapping)")
        }
        if ArenaCapabilitiesSectionA11yCaptions.hasChartPoints(capabilities.capabilities) {
            parts.append("gráfico comparativo disponível")
        }
        return parts.joined(separator: ", ")
    }

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
