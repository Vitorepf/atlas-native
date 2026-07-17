import Foundation
import AtlasCore

/// Spoken labels — peel de ArenaSuitesSection (CICLO C residual honesty).
/// Lista vazia = silêncio total; score/histórico só com dado publicado.

enum ArenaSuitesSectionA11y {
    static func spokenSection(_ suites: [AtlasArenaSuite]) -> String {
        let count = suites.count
        let measured = suites.filter(\.isMeasured).count
        let regressions = suites.filter(\.hasRegression).count
        let noun = count == 1 ? "suite" : "suites"
        var parts = ["\(count) \(noun)"]
        if measured < count {
            parts.append("\(measured) medidas")
        } else if measured > 0 {
            parts.append("todas medidas")
        }
        if regressions > 0 {
            let regNoun = regressions == 1 ? "regressão" : "regressões"
            parts.append("\(regressions) \(regNoun)")
        }
        return parts.joined(separator: ", ")
    }

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
