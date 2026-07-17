import Foundation
import AtlasCore

// Spoken labels — peel de ArenaSuiteSheet (CICLO C residual honesty).
// Casos/duração só quando o servidor publica; zero «0» fabricado.

enum ArenaSuiteSheetA11y {
    static func spokenSuiteTitle(_ suite: String) -> String {
        "suite \(suite)"
    }

    static func spokenEngine(_ engine: AtlasArenaSuiteEngine) -> String {
        var parts = [engine.engine, "score \(ArenaFormat.score(engine.score))"]
        if engine.regressed { parts.append("regressão detectada") }
        if let cases = casesCaption(for: engine) { parts.append(cases) }
        if let duration = durationCaption(for: engine) { parts.append(duration) }
        if !engine.history.isEmpty {
            parts.append("\(engine.history.count) pontos no histórico")
        }
        return parts.joined(separator: ", ")
    }

    static func casesCaption(for engine: AtlasArenaSuiteEngine) -> String? {
        guard let total = engine.casesTotal else { return nil }
        var parts: [String] = []
        if let passed = engine.casesPassed { parts.append("ok \(passed)") }
        if let failed = engine.casesFailed { parts.append("falha \(failed)") }
        parts.append("de \(total) casos")
        return parts.joined(separator: " · ")
    }

    static func durationCaption(for engine: AtlasArenaSuiteEngine) -> String? {
        guard let ms = engine.durationAvgMs else { return nil }
        return "duração média \(ms) milissegundos"
    }

    static let closeLabel = "fechar detalhes da suite"
    static let closeHint = "volta para a Arena"

    static func spokenSheet(_ suite: AtlasArenaSuite) -> String {
        let n = suite.engines.count
        if n == 0 {
            return "suite \(suite.suite), nenhum motor neste recorte"
        }
        return "suite \(suite.suite), \(n) motor\(n == 1 ? "" : "es")"
    }

    static let sheetHint = "scores, casos e duração só quando o servidor publica"
}
