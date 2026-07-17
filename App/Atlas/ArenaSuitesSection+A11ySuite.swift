import Foundation
import AtlasCore

// Spoken suite row — peel de ArenaSuitesSectionA11y.

extension ArenaSuitesSectionA11y {
    static func spokenSuite(_ suite: AtlasArenaSuite) -> String {
        var parts = [suite.suite]
        if !suite.adapterInstalled {
            parts.append("sem adapter instalado")
        }
        if suite.hasRegression {
            parts.append("regressão detectada")
        }
        if suite.isMeasured {
            parts.append(suite.arenaSubtitleText)
            if let engine = suite.engines.first, let score = engine.score {
                parts.append("score \(ArenaFormat.score(score))")
            }
            if hasSparkline(for: suite) {
                parts.append("histórico com pontos medidos")
            }
        } else {
            parts.append("não medida")
        }
        return parts.joined(separator: ", ")
    }

    static func hasSparkline(for suite: AtlasArenaSuite) -> Bool {
        guard let engine = suite.engines.first else { return false }
        return engine.history.contains { $0.score != nil }
    }
}
