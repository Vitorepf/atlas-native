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
        parts.append(spokenConfidence(capability))
        if let cases = ArenaCapabilitiesSectionA11yCaptions.casesCaption(for: capability) { parts.append(cases) }
        if let suites = ArenaCapabilitiesSectionA11yCaptions.suitesCaption(for: capability) { parts.append(suites) }
        return parts.joined(separator: ", ")
    }

    /// Confiança falada — a lei "número não confiável = não medido" também vale no VoiceOver.
    static func spokenConfidence(_ capability: AtlasArenaCapability) -> String {
        switch capability.confidenceLevel {
        case .unmeasured:
            return capability.withAtlas == nil ? "Atlas ainda não rodou aqui" : "sem par para comparar"
        case .low:
            let n = capability.withAtlasCases ?? capability.baselineCases ?? 0
            return "poucos casos, N \(n), baixa confiança"
        case .measured:
            let n = min(capability.baselineCases ?? 0, capability.withAtlasCases ?? 0)
            if capability.delta?.significant == true {
                return (capability.delta?.value ?? 0) >= 0
                    ? "Atlas melhora, confirmado, N \(n)"
                    : "Atlas piora, confirmado, N \(n)"
            }
            return "diferença dentro do ruído, N \(n)"
        }
    }
}
