import SwiftUI
import AtlasCore

// Spoken accessibility text — peel de ArenaEngineIndexRow+A11y.

extension ArenaEngineIndexRow {
    var accessibilityText: String {
        var parts = ["\(engine.engine), composto \(ArenaFormat.score(engine.composite))"]
        if let delta = engine.delta {
            parts.append("variação \(ArenaFormat.signed(delta))")
        }
        parts.append("com Atlas \(ArenaFormat.score(engine.withAtlasComposite))")
        if let multiplier = engine.atlasMultiplier {
            parts.append("multiplicador \(ArenaFormat.multiplier(multiplier))")
        }
        if engine.isPartialCoverage {
            parts.append("cobertura parcial \(Int((engine.coverage * 100).rounded())) por cento")
        }
        return parts.joined(separator: ", ")
    }
}
