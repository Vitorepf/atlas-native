import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive suite-drill face (WAVE-059).
enum ArenaSuiteFace: Equatable {
    case empty
    case quiet
    case regression(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .quiet: return "quiet"
        case .regression: return "regression"
        }
    }

    var kicker: String {
        switch self {
        case .empty: return "Suíte"
        case .quiet: return "Resultado da suíte"
        case .regression: return "Regressão detectada"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "nenhum motor neste recorte"
        case .quiet:
            return "suíte sem regressão publicada"
        case .regression(let n):
            return n == 1
                ? "1 motor com regressão"
                : "\(n) motores com regressão"
        }
    }
}

// MARK: - Judgment

/// Pure suite engines grammar — rank · face · spoken · pack.
enum ArenaSuiteJudgment {

    static let closeLabel = "fechar detalhes da suite"
    static let closeHint = "volta para a Arena"
    static let sheetHint = "scores, casos e duração só quando o servidor publica"

    static func spokenSuiteTitle(_ suite: String) -> String {
        "suite \(suite)"
    }

    /// Regressed first → measured score desc → wire-stable.
    static func rank(_ engines: [AtlasArenaSuiteEngine]) -> [AtlasArenaSuiteEngine] {
        engines.enumerated().sorted { lhs, rhs in
            let lReg = lhs.element.regressed
            let rReg = rhs.element.regressed
            if lReg != rReg { return lReg && !rReg }
            let lScore = lhs.element.score
            let rScore = rhs.element.score
            switch (lScore, rScore) {
            case let (l?, r?):
                if l != r { return l > r }
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                break
            }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func face(for suite: AtlasArenaSuite) -> ArenaSuiteFace {
        if suite.engines.isEmpty { return .empty }
        let regressed = suite.engines.filter(\.regressed).count
        if regressed > 0 { return .regression(regressed) }
        return .quiet
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

    static func spokenSuite(_ suite: AtlasArenaSuite) -> String {
        let face = face(for: suite)
        let n = suite.engines.count
        if n == 0 {
            return "suite \(suite.suite), \(face.spokenFace)"
        }
        let parts = [
            "suite \(suite.suite)",
            "\(n) motor\(n == 1 ? "" : "es")",
            face.spokenFace
        ]
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
        return "duração média \(ArenaDisplay.duration(ms: ms)) por caso"
    }

    static func packFacts(for suite: AtlasArenaSuite) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(for: suite)
        facts.append("arena_suite_face: \(face.productWord)")
        facts.append("suite: \(suite.suite)")
        facts.append("engines: \(suite.engines.count)")
        facts.append("runs_total: \(suite.runsTotal)")
        if suite.engines.isEmpty {
            absences.append("nenhum motor na suíte neste recorte")
            return (facts, absences)
        }
        for engine in rank(suite.engines).prefix(6) {
            var line = "engine: \(engine.engine)"
            if engine.regressed { line += " · regressed" }
            if let score = engine.score {
                line += " · score \(score)"
            } else {
                line += " · unmeasured"
            }
            facts.append(line)
        }
        let unmeasured = suite.engines.filter { $0.score == nil }.count
        if unmeasured > 0 {
            absences.append("\(unmeasured) motor(es) sem score publicado")
        }
        return (facts, absences)
    }

    // MARK: Composite chart spoken (IDLE · was ArenaCompositeChartA11y)

    static func spokenCompositeChart(_ engine: AtlasArenaCompositeEngine) -> String {
        let plotted = engine.history.filter {
            $0.composite != nil || $0.withAtlas != nil || $0.withoutAtlas != nil
        }
        guard !plotted.isEmpty else { return "" }
        var parts = ["gráfico de histórico do motor \(engine.engine)"]
        let rounds = plotted.count
        parts.append(rounds == 1 ? "1 rodada" : "\(rounds) rodadas")
        if plotted.contains(where: { $0.composite != nil }) { parts.append("linha composta") }
        if plotted.contains(where: { $0.withAtlas != nil }) { parts.append("linha com Atlas") }
        if plotted.contains(where: { $0.withoutAtlas != nil }) { parts.append("linha sem Atlas") }
        return parts.joined(separator: ", ")
    }
}
