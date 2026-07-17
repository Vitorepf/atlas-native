import Foundation
import AtlasCore

// Suite measured spoken — peel de ArenaSuitesSection+A11ySuite.

extension ArenaSuitesSectionA11y {
    static func spokenMeasuredParts(_ suite: AtlasArenaSuite) -> [String] {
        var parts = [suite.arenaSubtitleText]
        if let engine = suite.engines.first, let score = engine.score {
            parts.append("score \(ArenaFormat.score(score))")
        }
        if hasSparkline(for: suite) {
            parts.append("histórico com pontos medidos")
        }
        return parts
    }
}
