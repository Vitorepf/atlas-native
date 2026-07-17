import Foundation
import AtlasCore

// Engine summary spoken — peel de ArenaEngineSheet+A11y.

extension ArenaEngineSheetA11y {
    static func spokenSummary(_ engine: AtlasArenaCompositeEngine) -> String {
        var parts = ["composto \(ArenaFormat.score(engine.composite))"]
        if engine.withAtlasComposite != nil || engine.withoutAtlasComposite != nil {
            parts.append("com Atlas \(ArenaFormat.score(engine.withAtlasComposite))")
            parts.append("sem Atlas \(ArenaFormat.score(engine.withoutAtlasComposite))")
        }
        if let multiplier = engine.atlasMultiplier {
            parts.append("multiplicador \(ArenaFormat.multiplier(multiplier))")
        }
        if !engine.history.isEmpty {
            parts.append("\(engine.history.count) rodadas no gráfico")
        }
        return parts.joined(separator: ", ")
    }
}
