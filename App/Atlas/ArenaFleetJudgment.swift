import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: ArenaJudgments fused

// MARK: - ArenaFleetJudgment

// MARK: - Types

/// WAVE-157: fleet rank one law — pack ≡ FleetView “onde o Atlas sobe”.
enum ArenaFleetJudgment {

    // MARK: Rank

    /// Multiplier desc first; then composite desc; then engine id.
    static func rank(_ engines: [AtlasArenaCompositeEngine]) -> [AtlasArenaCompositeEngine] {
        engines.sorted { lhs, rhs in
            switch (lhs.atlasMultiplier, rhs.atlasMultiplier) {
            case let (l?, r?): return l > r
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil):
                switch (lhs.composite, rhs.composite) {
                case let (l?, r?): return l > r
                case (_?, nil): return true
                case (nil, _?): return false
                default: return lhs.engine < rhs.engine
                }
            }
        }
    }

    /// Best gain: first ranked with positive multiplier, else first with composite.
    static func best(in engines: [AtlasArenaCompositeEngine]) -> AtlasArenaCompositeEngine? {
        let ranked = rank(engines)
        return ranked.first { $0.atlasMultiplier != nil && ($0.atlasMultiplier ?? 0) > 0 }
            ?? ranked.first { $0.composite != nil }
    }

    // MARK: Pack

    static func packFacts(
        engines: [AtlasArenaCompositeEngine],
        limit: Int = 8
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let ranked = rank(engines)
        facts.append("frota_motores: \(ranked.count)")
        if ranked.isEmpty {
            absences.append("nenhum motor medido na frota")
            return (facts, absences)
        }
        if let best = best(in: ranked), let mult = best.atlasMultiplier {
            facts.append(
                "frota_melhor: \(ArenaDisplay.engine(best.engine)) · \(ArenaFormat.multiplier(mult))"
            )
        } else {
            absences.append("sem multiplicador positivo publicado na frota")
        }
        for engine in ranked.prefix(limit) {
            let mult = engine.atlasMultiplier.map(ArenaFormat.multiplier) ?? "não medido"
            facts.append(
                "frota · \(ArenaDisplay.engine(engine.engine)): \(mult) (sem \(ArenaFormat.score(engine.withoutAtlasComposite)) → com \(ArenaFormat.score(engine.withAtlasComposite)))"
            )
        }
        return (facts, absences)
    }
}
// MARK: - ArenaPipelineJudgment

// MARK: - Judgment

/// Pure Arena execution pipeline projection (WAVE-109).
/// Never invents arm marks beyond published live runs + report flag.
enum ArenaPipelineJudgment {

    static func project(
        runs: [AtlasArenaLiveRun],
        expectsBare: Bool,
        expectsAtlas: Bool,
        hasReport: Bool
    ) -> ArenaPremiumPipelineProjection {
        var marks: [ArenaPremiumPipelineStep: ArenaPremiumPipelineMark] = [:]
        let bare = runs.filter { $0.arm == .baseline }
        let atlas = runs.filter { $0.arm == .withAtlas }
        let allQueued = !runs.isEmpty && runs.allSatisfy {
            if case .queued = $0.status { return true }
            return false
        }
        let allTerminal = !runs.isEmpty && runs.allSatisfy(isTerminal)

        if runs.isEmpty {
            marks[.prepare] = .pending
        } else if allQueued {
            marks[.prepare] = .live
        } else {
            marks[.prepare] = .done
        }

        marks[.bare] = armMark(
            bare,
            expected: expectsBare || !bare.isEmpty,
            prepareDone: marks[.prepare] == .done
        )
        marks[.withAtlas] = armMark(
            atlas,
            expected: expectsAtlas || !atlas.isEmpty,
            prepareDone: marks[.prepare] == .done
        )

        if allTerminal {
            marks[.consolidate] = hasReport ? .done : .live
        } else {
            marks[.consolidate] = .pending
        }

        return ArenaPremiumPipelineProjection(marks: marks)
    }

    static func armMark(
        _ armRuns: [AtlasArenaLiveRun],
        expected: Bool,
        prepareDone: Bool
    ) -> ArenaPremiumPipelineMark {
        guard expected else { return prepareDone ? .done : .pending }
        if armRuns.contains(where: {
            if case .running = $0.status { return true }
            if case .stopping = $0.status { return true }
            return false
        }) {
            return .live
        }
        if !armRuns.isEmpty, armRuns.allSatisfy(isTerminal) {
            return .done
        }
        return .pending
    }

    static func isTerminal(_ run: AtlasArenaLiveRun) -> Bool {
        switch run.status {
        case .completed, .failed, .stopped: return true
        default: return false
        }
    }

    /// Corrida ao vivo usa ▸; ✦ só na fase cujo nome é Atlas.
    static func glyph(step: ArenaPremiumPipelineStep, mark: ArenaPremiumPipelineMark) -> String {
        switch mark {
        case .done: return "✓"
        case .pending: return "○"
        case .live:
            return step == .withAtlas ? "✦" : "▸"
        }
    }

    static func color(for mark: ArenaPremiumPipelineMark) -> Color {
        switch mark {
        case .live: return AtlasTheme.accent
        case .done: return AtlasTheme.textPrimary
        case .pending: return AtlasTheme.textTertiary
        }
    }

    static func spoken(_ projection: ArenaPremiumPipelineProjection) -> String {
        ArenaPremiumPipelineStep.allCases.map { step in
            let mark = projection.marks[step] ?? .pending
            let state: String
            switch mark {
            case .done: state = "feito"
            case .live: state = "ao vivo"
            case .pending: state = "pendente"
            }
            return "\(step.title) \(state)"
        }.joined(separator: ", ")
    }

    static func packFacts(
        _ projection: ArenaPremiumPipelineProjection
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        for step in ArenaPremiumPipelineStep.allCases {
            let mark = projection.marks[step] ?? .pending
            let word: String
            switch mark {
            case .done: word = "done"
            case .live: word = "live"
            case .pending: word = "pending"
            }
            facts.append("pipeline_\(step.title): \(word)")
        }
        if projection.marks.values.allSatisfy({ $0 == .pending }) {
            absences.append("pipeline sem marcos vivos neste recorte")
        }
        return (facts, absences)
    }
}
// MARK: - ArenaPlanQueueJudgment

// MARK: - Types

/// Exclusive Arena plan destination face (WAVE-085).
enum ArenaPlanFace: Equatable {
    case empty
    case published
    case derivedLive

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .published: return "published"
        case .derivedLive: return "derived_live"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty: return "nenhum plano ativo"
        case .published: return "plano publicado"
        case .derivedLive: return "plano derivado da medição em curso"
        }
    }

    var footer: String {
        switch self {
        case .empty:
            return "Crie uma medição para organizar suítes, motores e braços."
        case .published:
            return "A seleção enviada pode avançar; casos concluídos não são reabertos."
        case .derivedLive:
            return "Ordem derivada da medição em curso; casos concluídos não são reabertos."
        }
    }
}

/// Exclusive Arena queue destination face (WAVE-085).
enum ArenaQueueFace: Equatable {
    case empty
    case active(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .active: return "active"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty: return "fila vazia"
        case .active(let n):
            return n == 1 ? "1 suíte na fila" : "\(n) suítes na fila"
        }
    }
}

// MARK: - Judgment

/// Pure Arena plan/queue grammar — faces · suite status rollup · pack.
enum ArenaPlanQueueJudgment {

    /// Live ∪ queue runs, dedup suite|arm, measurement first then queue.
    static func mergedLiveRuns(
        measurementRuns: [AtlasArenaLiveRun],
        queuedRuns: [AtlasArenaLiveRun]
    ) -> [AtlasArenaLiveRun] {
        var seen = Set<String>()
        return (measurementRuns + queuedRuns).compactMap { run in
            seen.insert("\(run.suite)|\(run.arm?.rawValue ?? "")").inserted ? run : nil
        }
    }

    static func liveSuites(from runs: [AtlasArenaLiveRun]) -> [String] {
        var seen = Set<String>()
        return runs.compactMap { seen.insert($0.suite).inserted ? $0.suite : nil }
    }

    static func planFace(
        activePlan: AtlasArenaMeasurementPlan?,
        liveSuites: [String]
    ) -> ArenaPlanFace {
        if activePlan != nil { return .published }
        if !liveSuites.isEmpty { return .derivedLive }
        return .empty
    }

    static func queueFace(queuedSuiteCount: Int) -> ArenaQueueFace {
        queuedSuiteCount <= 0 ? .empty : .active(queuedSuiteCount)
    }

    /// Suite status rollup priority: running → stopping → queued → failed → all-completed → stopped.
    static func suiteStatus(
        suite: String,
        measurementRuns: [AtlasArenaLiveRun]
    ) -> AtlasArenaRunStatus? {
        let statuses = measurementRuns.filter { $0.suite == suite }.map(\.status)
        if statuses.contains(.running) { return .running }
        if statuses.contains(.stopping) { return .stopping }
        if statuses.contains(.queued) { return .queued }
        if statuses.contains(.failed) { return .failed }
        if !statuses.isEmpty, statuses.allSatisfy({ $0 == .completed }) { return .completed }
        if statuses.contains(.stopped) { return .stopped }
        return nil
    }

    static func suiteTone(_ status: AtlasArenaRunStatus?) -> ArenaPremiumTone {
        guard let status else { return .neutral }
        return ArenaRunStatusJudgment.tone(for: status)
    }

    static func planPackFacts(
        activePlan: AtlasArenaMeasurementPlan?,
        measurementRuns: [AtlasArenaLiveRun],
        queuedRuns: [AtlasArenaLiveRun]
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let live = mergedLiveRuns(measurementRuns: measurementRuns, queuedRuns: queuedRuns)
        let suites = liveSuites(from: live)
        let face = planFace(activePlan: activePlan, liveSuites: suites)
        facts.append("arena_plan_face: \(face.productWord)")
        switch face {
        case .empty:
            absences.append("sem plano multi-suíte publicado e sem corridas vivas")
        case .published:
            facts.append("plano_ativo: sim")
            if let plan = activePlan {
                facts.append("plan_engines: \(plan.engines.count)")
                facts.append("plan_suites: \(plan.suites.count)")
                facts.append("plan_runs_planned: \(plan.runsPlanned)")
            }
        case .derivedLive:
            facts.append("plano_ativo: derived_live")
            facts.append("plan_suites_derived: \(suites.count)")
            facts.append("plan_runs_live: \(live.count)")
            // Explicit honesty: UI shows suites; pack must not claim absence.
        }
        return (facts, absences)
    }

    static func queuePackFacts(
        queuedRuns: [AtlasArenaLiveRun]
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let suites = liveSuites(from: queuedRuns)
        let face = queueFace(queuedSuiteCount: suites.count)
        facts.append("arena_queue_face: \(face.productWord)")
        facts.append("queue_runs: \(queuedRuns.count)")
        facts.append("queue_suites: \(suites.count)")
        if case .empty = face {
            absences.append("fila de execução vazia")
        }
        return (facts, absences)
    }
}
// MARK: - ArenaRunSheetJudgment

// MARK: - Types

/// Exclusive Arena run-sheet shell face (WAVE-074).
enum ArenaRunSheetFace: Equatable {
    case emptyEngines
    case emptySuites
    case ready(engines: Int, suites: Int)

    var productWord: String {
        switch self {
        case .emptyEngines: return "empty_engines"
        case .emptySuites: return "empty_suites"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .emptyEngines:
            return "nenhum motor publicado"
        case .emptySuites:
            return "nenhuma suite com adapter"
        case .ready(let engines, let suites):
            let e = engines == 1 ? "1 motor" : "\(engines) motores"
            let s = suites == 1 ? "1 suite instalada" : "\(suites) suites instaladas"
            return "\(e), \(s)"
        }
    }
}

// MARK: - Judgment

/// Pure Arena run-sheet shell grammar — face · spoken · pack.
enum ArenaRunSheetJudgment {

    static let productSheetTitle = "rodar medição Arena"
    static let spokenSheetHint =
        "escolhe suites, motor e braços; ator e motivo auditáveis são obrigatórios"
    static let spokenClose = "fechar folha de medição"
    static let spokenCloseHint = "volta para a Arena sem enviar"
    static let spokenActorHint = "nome de quem autoriza a medição"
    static let spokenReasonHint = "motivo auditável registrado no ledger"

    static func face(engineCount: Int, suiteCount: Int) -> ArenaRunSheetFace {
        if engineCount <= 0 { return .emptyEngines }
        if suiteCount <= 0 { return .emptySuites }
        return .ready(engines: engineCount, suites: suiteCount)
    }

    static func spokenSheet(face: ArenaRunSheetFace) -> String {
        "\(productSheetTitle), \(face.spokenFace)"
    }

    static func spokenEmptyEngines() -> String {
        "nenhum motor publicado pelo servidor, rodar medição indisponível"
    }

    static func spokenEmptySuites() -> String {
        "nenhuma suite com adapter instalado, rodar medição indisponível"
    }

    static func spokenErrorLabel(_ message: String) -> String {
        "erro: \(message)"
    }

    static func packFacts(engineCount: Int, suiteCount: Int) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(engineCount: engineCount, suiteCount: suiteCount)
        facts.append("arena_run_sheet_face: \(face.productWord)")
        facts.append("arena_run_engines: \(engineCount)")
        facts.append("arena_run_suites: \(suiteCount)")
        switch face {
        case .emptyEngines:
            absences.append("sem motores publicados para rodar")
        case .emptySuites:
            absences.append("sem suites com adapter instalado")
        case .ready:
            break
        }
        return (facts, absences)
    }
}
// MARK: - ArenaRunStatusJudgment

// MARK: - Judgment

/// Exclusive Arena live-run status chrome (WAVE-107).
/// One law for Execution row · Detail kicker · Icon glyph · pack word.
/// Never invents progress % beyond published casesDone/casesTotal.
enum ArenaRunStatusJudgment {

    // MARK: Label / tone / glyph

    /// Product kicker for a single run status (Detail + row dialect).
    static func productLabel(for status: AtlasArenaRunStatus) -> String {
        switch status {
        case .running: return "Ao vivo"
        case .stopping: return "Parando"
        case .queued: return "Na fila"
        case .completed: return "Concluída"
        case .failed: return "Falhou"
        case .stopped: return "Parada"
        case .unknown: return "Estado"
        }
    }

    static func tone(for status: AtlasArenaRunStatus) -> ArenaPremiumTone {
        switch status {
        case .queued, .running, .stopping: return .active
        case .completed: return .positive
        case .failed: return .negative
        case .stopped, .unknown: return .neutral
        }
    }

    /// Compact list glyph — never Atlas ✦ on runs.
    static func rowGlyph(for status: AtlasArenaRunStatus) -> String {
        switch status {
        case .running, .stopping: return "▸"
        case .completed: return "✓"
        case .failed: return "※"
        case .queued: return "◷"
        case .stopped, .unknown: return "·"
        }
    }

    /// SF Symbol for icon chrome (Icon.run).
    static func sfSymbol(for status: AtlasArenaRunStatus) -> String {
        switch status {
        case .queued: return "clock"
        case .running: return "play.circle"
        case .stopping: return "hourglass"
        case .stopped: return "stop.circle"
        case .completed: return "checkmark.circle"
        case .failed: return "exclamationmark.triangle"
        case .unknown: return "questionmark.circle"
        }
    }

    static func productWord(for status: AtlasArenaRunStatus) -> String {
        switch status {
        case .running: return "running"
        case .stopping: return "stopping"
        case .queued: return "queued"
        case .completed: return "completed"
        case .failed: return "failed"
        case .stopped: return "stopped"
        case .unknown: return "unknown"
        }
    }

    static func spoken(for status: AtlasArenaRunStatus) -> String {
        productLabel(for: status)
    }

    // MARK: Row chrome

    static func rowDetail(_ run: AtlasArenaLiveRun) -> String {
        if let done = run.casesDone, let total = run.casesTotal, total > 0 {
            return "\(done)/\(total) casos"
        }
        return run.arm?.labelPT ?? run.status.displayPT
    }

    static func rowTrailing(_ run: AtlasArenaLiveRun) -> String {
        let arm = run.arm?.labelPT
        let state: String
        switch run.status {
        case .running: state = "ao vivo"
        case .stopping: state = "parando"
        case .queued: state = "na fila"
        case .completed: state = "concluída"
        case .failed: state = "falhou"
        case .stopped: state = "parada"
        case .unknown: state = run.status.displayPT
        }
        return [state, arm].compactMap(\.self).joined(separator: " · ")
    }

    /// Detail cases summary (honest published fractions only).
    static func casesSummaryLine(
        status: AtlasArenaRunStatus,
        done: Int,
        total: Int
    ) -> String {
        let remaining = max(0, total - done)
        switch status {
        case .running, .stopping:
            return "\(done) confirmados · 1 em andamento · \(max(0, remaining - 1)) a seguir"
        case .queued:
            return "\(total) na fila · ainda não iniciado"
        case .completed:
            return "\(done) de \(total) concluídos"
        case .failed:
            return "\(done) de \(total) antes da falha"
        case .stopped:
            return "\(done) de \(total) quando parou"
        case .unknown:
            return "\(done) de \(total)"
        }
    }

    // MARK: Pack

    static func packFacts(for status: AtlasArenaRunStatus) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("arena_run_status: \(productWord(for: status))")
        facts.append("arena_run_label: \(productLabel(for: status))")
        if case .unknown = status {
            absences.append("status de corrida desconhecido — silêncio neutro")
        }
        return (facts, absences)
    }
}
