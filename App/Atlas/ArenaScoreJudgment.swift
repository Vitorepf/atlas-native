import Foundation
import SwiftUI
import AtlasCore

// WAVE-021 — uma gramática de julgamento de scoreboard (Results · Fleet ·
// Capabilities · Alerts · Comparison). Nunca fabrica 0; Δ só com par publicado.

/// Estados exclusivos do instrumento de julgamento.
enum ArenaScoreJudgmentState: String, Equatable {
    case unmeasured
    case partial
    case published
    case regressed
    case quietHealthy
}

enum ArenaScoreJudgment {
    /// Escala canônica — uma voz em todas as faces.
    static let scaleCaption = "escala 0–10"
    static let unmeasuredLabel = "não medido"
    static let absenceNeverZero =
        "Resultados ausentes aparecem como não medidos, nunca como zero."

    // MARK: - Classification

    /// Motor composto: unmeasured | partial | published | regressed.
    static func state(
        composite: Double?,
        without: Double?,
        withAtlas: Double?,
        claimAllowed: Bool?,
        isPartialCoverage: Bool,
        hasRegression: Bool
    ) -> ArenaScoreJudgmentState {
        if hasRegression { return .regressed }
        let hasAny = composite != nil || without != nil || withAtlas != nil
        if !hasAny { return .unmeasured }
        if isPartialCoverage || claimAllowed == false { return .partial }
        if without != nil, withAtlas != nil { return .published }
        if composite != nil { return .partial }
        return .unmeasured
    }

    static func state(engine: AtlasArenaCompositeEngine, claimAllowed: Bool?) -> ArenaScoreJudgmentState {
        state(
            composite: engine.composite,
            without: engine.withoutAtlasComposite,
            withAtlas: engine.withAtlasComposite,
            claimAllowed: claimAllowed,
            isPartialCoverage: engine.isPartialCoverage,
            hasRegression: false
        )
    }

    /// Alertas / quiet: se não há regressões nem attention = quiet-healthy.
    static func alertsState(regressionCount: Int, attentionCount: Int) -> ArenaScoreJudgmentState {
        if regressionCount + attentionCount > 0 { return .regressed }
        return .quietHealthy
    }

    // MARK: - Numbers (never fabricate)

    /// Δ com vs sem — só se **ambos** publicados; senão nil (não 0).
    static func pairedDelta(without: Double?, withAtlas: Double?) -> Double? {
        guard let without, let withAtlas else { return nil }
        return withAtlas - without
    }

    static func pairedDelta(engine: AtlasArenaCompositeEngine) -> Double? {
        pairedDelta(without: engine.withoutAtlasComposite, withAtlas: engine.withAtlasComposite)
    }

    /// Lei Comparison: só mostra kicker/par se o par completo existe.
    static func shouldShowComparison(without: Double?, withAtlas: Double?) -> Bool {
        without != nil && withAtlas != nil
    }

    static func comparisonKicker(provisional: Bool, sourceSuite: Bool) -> String {
        if sourceSuite {
            return provisional
                ? "Último par · \(scaleCaption)"
                : "Comparação final · \(scaleCaption)"
        }
        return provisional
            ? "Índice do motor · \(scaleCaption)"
            : "Comparação final · \(scaleCaption)"
    }

    // MARK: - Kickers / voice

    static func resultsKicker(claimAllowed: Bool?) -> String {
        if claimAllowed == true { return "Última medição concluída · \(scaleCaption)" }
        return "Medição parcial · \(scaleCaption)"
    }

    static func fleetKicker(engineCount: Int) -> String {
        let n = engineCount
        return "Frota medida · \(n) \(n == 1 ? "motor" : "motores") · \(scaleCaption)"
    }

    static func spokenMeasuredEngine(_ engineID: String) -> String {
        "Motor medido, \(ArenaDisplay.engine(engineID))"
    }

    static let measuredEngineHint = "Abre a lista dos outros motores medidos"

    static func capabilitiesKicker() -> String {
        "Perfil medido · \(scaleCaption)"
    }

    static func alertsKicker(hasAlerts: Bool) -> (text: String, tone: ArenaPremiumTone) {
        if hasAlerts {
            return ("Exceções que pedem atenção · \(scaleCaption)", .negative)
        }
        return ("Sem exceções · quiet-healthy", .positive)
    }

    /// Voz única de regressão (Alerts ≡ Results).
    static func regressionDetail(delta: Double?) -> String {
        "\(ArenaFormat.signed(delta)) · regressão"
    }

    // MARK: - Spoken (≡ visual)

    static func spokenScore(_ value: Double?) -> String {
        guard value != nil else { return unmeasuredLabel }
        return "\(ArenaFormat.score(value)) de 10"
    }

    static func spokenPair(without: Double?, withAtlas: Double?) -> String {
        guard shouldShowComparison(without: without, withAtlas: withAtlas) else {
            return "par com/sem Atlas \(unmeasuredLabel)"
        }
        let d = pairedDelta(without: without, withAtlas: withAtlas)
        return "Sem Atlas \(ArenaFormat.score(without)), com Atlas \(ArenaFormat.score(withAtlas)), diferença \(ArenaFormat.signed(d))"
    }

    static func spokenEngine(_ engine: AtlasArenaCompositeEngine) -> String {
        let name = ArenaDisplay.engine(engine.engine)
        if let mult = engine.atlasMultiplier {
            return "\(name), multiplicador \(ArenaFormat.multiplier(mult)), \(spokenPair(without: engine.withoutAtlasComposite, withAtlas: engine.withAtlasComposite))"
        }
        if engine.composite == nil && engine.withoutAtlasComposite == nil && engine.withAtlasComposite == nil {
            return "\(name), \(unmeasuredLabel)"
        }
        return "\(name), \(spokenPair(without: engine.withoutAtlasComposite, withAtlas: engine.withAtlasComposite))"
    }

    // MARK: Pack (WAVE-181)

    /// Mid-pack scoreboard state — never fabricates 0 or incomplete Δ.
    static func packFacts(
        engine: AtlasArenaCompositeEngine?,
        claimAllowed: Bool?,
        regressionCount: Int = 0,
        attentionCount: Int = 0
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []

        guard let engine else {
            facts.append("score_state: \(ArenaScoreJudgmentState.unmeasured.rawValue)")
            absences.append(unmeasuredLabel)
            absences.append(absenceNeverZero)
            return (facts, absences)
        }

        let face = state(engine: engine, claimAllowed: claimAllowed)
        // Host suite regressions elevate state without inventing engine flags.
        let scoreState: ArenaScoreJudgmentState =
            (regressionCount > 0 || attentionCount > 0) ? .regressed : face

        facts.append("score_state: \(scoreState.rawValue)")
        facts.append("score_engine: \(ArenaDisplay.engine(engine.engine))")
        if let composite = engine.composite {
            facts.append("score_composite: \(ArenaFormat.score(composite))")
        } else {
            absences.append("composite \(unmeasuredLabel)")
        }
        if let without = engine.withoutAtlasComposite {
            facts.append("score_without_atlas: \(ArenaFormat.score(without))")
        } else {
            absences.append("braço sem Atlas \(unmeasuredLabel)")
        }
        if let withAtlas = engine.withAtlasComposite {
            facts.append("score_with_atlas: \(ArenaFormat.score(withAtlas))")
        } else {
            absences.append("braço com Atlas \(unmeasuredLabel)")
        }
        if let delta = pairedDelta(engine: engine) {
            facts.append("score_delta_atlas: \(ArenaFormat.signed(delta))")
        } else {
            absences.append("par com/sem Atlas incompleto — sem Δ inventado")
        }
        if let mult = engine.atlasMultiplier {
            facts.append("score_multiplier: \(ArenaFormat.multiplier(mult))")
        }
        if engine.isPartialCoverage {
            facts.append("score_coverage: partial")
        }
        if claimAllowed == false {
            absences.append("claim_allowed=false — medição parcial, não trate como veredito final")
        }
        if regressionCount > 0 {
            facts.append("score_suite_regressions: \(regressionCount)")
        }
        absences.append(absenceNeverZero)
        return (facts, absences)
    }
}
