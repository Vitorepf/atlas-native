import Foundation
import AtlasCore

/// Engine row spoken — peel de ArenaIndexSection+A11y.

extension ArenaIndexSection {
    func engineRowSpoken(_ engine: AtlasArenaCompositeEngine) -> String {
        let delta = engine.delta.map { ", variação \(ArenaFormat.signed($0))" } ?? ""
        let partial = engine.isPartialCoverage
            ? ", cobertura parcial \(Int((engine.coverage * 100).rounded())) por cento" : ""
        return "\(engine.engine), composto \(ArenaFormat.score(engine.composite))\(delta)\(partial)"
    }
}
