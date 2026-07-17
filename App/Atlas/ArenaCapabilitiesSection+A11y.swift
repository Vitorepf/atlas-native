import Foundation
import AtlasCore

/// Spoken labels — peel de ArenaCapabilitiesSection (CICLO C residual honesty).
/// Casos/suites só quando o servidor publica; gráfico decorativo.

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
        if hasChartPoints(capabilities.capabilities) {
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
        if let cases = casesCaption(for: capability) { parts.append(cases) }
        if let suites = suitesCaption(for: capability) { parts.append(suites) }
        return parts.joined(separator: ", ")
    }

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
