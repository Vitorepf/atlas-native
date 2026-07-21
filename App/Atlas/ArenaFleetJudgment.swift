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

    static let sheetTitle = "rodar medição Arena"
    static let sheetHint =
        "escolhe suites, motor e braços; ator e motivo auditáveis são obrigatórios"
    static let closeLabel = "fechar folha de medição"
    static let closeHint = "volta para a Arena sem enviar"
    static let actorHint = "nome de quem autoriza a medição"
    static let reasonHint = "motivo auditável registrado no ledger"

    static func face(engineCount: Int, suiteCount: Int) -> ArenaRunSheetFace {
        if engineCount <= 0 { return .emptyEngines }
        if suiteCount <= 0 { return .emptySuites }
        return .ready(engines: engineCount, suites: suiteCount)
    }

    static func spokenSheet(face: ArenaRunSheetFace) -> String {
        "\(sheetTitle), \(face.spokenFace)"
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
    static func label(for status: AtlasArenaRunStatus) -> String {
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
        label(for: status)
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
        facts.append("arena_run_label: \(label(for: status))")
        if case .unknown = status {
            absences.append("status de corrida desconhecido — silêncio neutro")
        }
        return (facts, absences)
    }
}
// MARK: - ArenaStopJudgment

// MARK: - Types

/// Exclusive Arena stop-sheet face (WAVE-108).
enum ArenaStopFace: Equatable {
    case blocked
    case ready

    var productWord: String {
        switch self {
        case .blocked: return "blocked"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .blocked:
            return "parada bloqueada, preencha operador e motivo"
        case .ready:
            return "pronta para confirmar a parada"
        }
    }
}

// MARK: - Judgment

/// Pure Arena stop governance grammar — face · spoken · pack.
enum ArenaStopJudgment {

    static let navigationTitle = "Parar"
    static let kicker = "Ação governada"
    static let heroTitle = "Parar a medição?"
    static let bodyCopy =
        "O caso atual termina antes da parada. Casos concluídos e resultados parciais são preservados."
    static let actorLabel = "Operador"
    static let reasonLabel = "Motivo"
    static let actorPlaceholder = "quem autoriza"
    static let reasonPlaceholder = "por que parar agora"
    static let confirmTitle = "Confirmar parada"
    static let closeSpoken = "fechar confirmação"
    static let closeHint = "mantém a medição em execução"
    static let confirmHint = "envia a parada governada com operador e motivo"

    static func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func face(actor: String, reason: String) -> ArenaStopFace {
        canSubmit(actor: actor, reason: reason) ? .ready : .blocked
    }

    static func canSubmit(actor: String, reason: String) -> Bool {
        !trimmed(actor).isEmpty && !trimmed(reason).isEmpty
    }

    static func spokenSheet(suite: String) -> String {
        "parar medição \(suite), \(face(actor: "", reason: "").spokenFace)"
    }

    static func spokenSheet(actor: String, reason: String, suite: String) -> String {
        "parar medição \(suite), \(face(actor: actor, reason: reason).spokenFace)"
    }

    static func spokenConfirm(actor: String, reason: String) -> String {
        let face = face(actor: actor, reason: reason)
        switch face {
        case .blocked:
            return "confirmar parada indisponível, \(face.spokenFace)"
        case .ready:
            return "confirmar parada, operador \(trimmed(actor))"
        }
    }

    static func spokenReceipt(_ receipt: AtlasArenaStopReceipt) -> String {
        "parada registrada, medição \(receipt.measurementIdPublic)"
    }

    static func packFacts(
        actor: String,
        reason: String,
        hasMatchingReceipt: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(actor: actor, reason: reason)
        facts.append("arena_stop_face: \(face.productWord)")
        if trimmed(actor).isEmpty {
            absences.append("operador da parada vazio")
        } else {
            facts.append("stop_actor_present: true")
        }
        if trimmed(reason).isEmpty {
            absences.append("motivo da parada vazio")
        } else {
            facts.append("stop_reason_present: true")
        }
        if hasMatchingReceipt {
            facts.append("stop_receipt: published")
        } else {
            absences.append("sem recibo de parada nesta medição")
        }
        return (facts, absences)
    }
}

// MARK: - ArenaCapabilitiesJudgment

// MARK: - Types

/// Exclusive Arena capabilities list face (WAVE-094).
enum ArenaCapabilitiesFace: Equatable {
    case empty
    case list(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .list(let n): return "list(\(n))"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "capacidades ainda não medidas"
        case .list(let n):
            let noun = n == 1 ? "capacidade" : "capacidades"
            return "\(n) \(noun)"
        }
    }
}

/// Attention tone for summary metrics (presentation).
enum ArenaCapabilitiesDeltaTone: Equatable {
    case positive
    case neutral
    case negative
}

// MARK: - Counts (one law)

/// Pure measured/improved/regressed counts — UI ≡ pack (WAVE-094).
/// measured = confidenceLevel.measured only (score presence ≠ measured).
struct ArenaCapabilitiesCounts: Equatable {
    let total: Int
    let measured: Int
    let improved: Int
    let regressed: Int
    let stable: Int

    var unmeasured: Int { max(0, total - measured) }
}

// MARK: - Judgment

/// Pure capabilities confidence grammar — face · counts · rank · spoken · pack.
enum ArenaCapabilitiesJudgment {

    static let emptyTitle = "Capacidades ainda não medidas"
    static let emptyBody = "Ausência permanece ausência — nenhuma barra começa em zero."
    static let coveredLabel = "capacidades cobertas"
    static let groupOrder = ["construction", "comprehension", "quality", "agentic"]

    // MARK: Face / counts

    static func face(_ capabilities: [AtlasArenaCapability]) -> ArenaCapabilitiesFace {
        capabilities.isEmpty ? .empty : .list(capabilities.count)
    }

    static func isMeasured(_ capability: AtlasArenaCapability) -> Bool {
        capability.confidenceLevel == .measured
    }

    static func isSignificantImproved(_ capability: AtlasArenaCapability) -> Bool {
        guard isMeasured(capability),
              capability.delta?.significant == true,
              let value = capability.delta?.value else { return false }
        return value > 0
    }

    static func isSignificantRegressed(_ capability: AtlasArenaCapability) -> Bool {
        guard isMeasured(capability),
              capability.delta?.significant == true,
              let value = capability.delta?.value else { return false }
        return value < 0
    }

    static func counts(of capabilities: [AtlasArenaCapability]) -> ArenaCapabilitiesCounts {
        let measured = capabilities.filter(isMeasured).count
        let improved = capabilities.filter(isSignificantImproved).count
        let regressed = capabilities.filter(isSignificantRegressed).count
        let stable = max(0, measured - improved - regressed)
        return ArenaCapabilitiesCounts(
            total: capabilities.count,
            measured: measured,
            improved: improved,
            regressed: regressed,
            stable: stable
        )
    }

    // MARK: Rank — regressed-first · low confidence · wire-stable

    /// 0 regressed significant · 1 low confidence · 2 unmeasured · 3 measured noise · 4 improved
    static func attentionRank(_ capability: AtlasArenaCapability) -> Int {
        if isSignificantRegressed(capability) { return 0 }
        switch capability.confidenceLevel {
        case .low: return 1
        case .unmeasured: return 2
        case .measured:
            if isSignificantImproved(capability) { return 4 }
            return 3
        }
    }

    static func rank(_ capabilities: [AtlasArenaCapability]) -> [AtlasArenaCapability] {
        capabilities.enumerated().sorted { lhs, rhs in
            let lr = attentionRank(lhs.element)
            let rr = attentionRank(rhs.element)
            if lr != rr { return lr < rr }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func members(
        in group: String,
        capabilities: [AtlasArenaCapability]
    ) -> [AtlasArenaCapability] {
        let filtered = capabilities.filter { ($0.group ?? "quality") == group }
        return rank(filtered)
    }

    // MARK: shortConfidence / spoken / delta chrome

    static func shortConfidence(_ capability: AtlasArenaCapability) -> String? {
        if let gated = capability.gatedReason, !gated.isEmpty {
            return gated
        }
        switch capability.confidenceLevel {
        case .measured:
            return capability.delta?.significant == true ? nil : "dentro do ruído"
        case .low:
            let n = capability.withAtlasCases ?? capability.baselineCases ?? 0
            return "poucos casos (N \(n)) · baixa confiança"
        case .unmeasured:
            if let rate = capability.maxExclusionRate, rate >= 0.5 {
                return "\(Int((rate * 100).rounded()))% descartado no setup · não medível"
            }
            return capability.withAtlas == nil ? "Atlas ainda não rodou aqui" : "não medível"
        }
    }

    static func deltaValue(_ capability: AtlasArenaCapability) -> Double? {
        capability.delta?.value
    }

    static func deltaDisplayText(_ capability: AtlasArenaCapability) -> String {
        capability.confidenceLevel == .unmeasured
            ? "—"
            : ArenaFormat.signed(deltaValue(capability))
    }

    static func deltaTone(_ capability: AtlasArenaCapability) -> ArenaCapabilitiesDeltaTone {
        switch capability.confidenceLevel {
        case .unmeasured, .low:
            return .neutral
        case .measured:
            guard capability.delta?.significant == true, let value = deltaValue(capability) else {
                return .neutral
            }
            return value > 0 ? .positive : .negative
        }
    }

    static func deltaColor(_ capability: AtlasArenaCapability) -> Color {
        switch deltaTone(capability) {
        case .positive: return AtlasTheme.textPrimary
        case .negative: return AtlasTheme.alert
        case .neutral:
            switch capability.confidenceLevel {
            case .unmeasured, .low: return AtlasTheme.textTertiary
            case .measured: return AtlasTheme.textSecondary
            }
        }
    }

    static func spokenRow(_ capability: AtlasArenaCapability) -> String {
        let base = "\(capability.labelPt), sem Atlas \(ArenaFormat.score(capability.score)), com Atlas \(ArenaFormat.score(capability.withAtlas)), diferença \(ArenaFormat.signed(deltaValue(capability)))"
        guard let caption = shortConfidence(capability) else { return base }
        return "\(base), \(caption)"
    }

    static func capabilitiesCaption(engineOptionCount: Int) -> String {
        if engineOptionCount > 1 {
            return "Toque no nome do motor para ver outro perfil medido. Cada capacidade abre as suítes que alimentaram a medida."
        }
        return "Cada capacidade abre as suítes e os casos que contribuíram para a medida."
    }

    // MARK: Pack — never score-presence as “cobertas”

    static func packFacts(
        _ capabilities: [AtlasArenaCapability]
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(capabilities)
        let c = counts(of: capabilities)
        facts.append("capabilities_face: \(face.productWord)")
        facts.append("capabilities_total: \(c.total)")
        facts.append("capabilities_measured: \(c.measured)")
        facts.append("capabilities_improved: \(c.improved)")
        facts.append("capabilities_regressed: \(c.regressed)")
        facts.append("capabilities_stable: \(c.stable)")
        facts.append("capabilities_unmeasured: \(c.unmeasured)")
        // Explicit honesty: score presence is NOT measured coverage.
        let scorePresence = capabilities.filter { $0.score != nil || $0.withAtlas != nil }.count
        if scorePresence != c.measured {
            facts.append("capabilities_score_presence: \(scorePresence) (≠ measured)")
            absences.append("score presence ≠ confidence measured — não vender como cobertas")
        }
        switch face {
        case .empty:
            absences.append("nenhuma capacidade publicada neste motor")
        case .list:
            for cap in rank(capabilities).prefix(8) {
                let conf = cap.confidenceLevel.rawValue
                facts.append(
                    "cap · \(cap.labelPt): conf \(conf) · sem \(ArenaFormat.score(cap.score)) → com \(ArenaFormat.score(cap.withAtlas)) (\(ArenaFormat.signed(deltaValue(cap))))"
                )
            }
        }
        return (facts, absences)
    }
}

// MARK: - ArenaLiveControlJudgment

// MARK: - Types

/// Exclusive Arena live-control face (WAVE-050).
enum ArenaLiveControlFace: Equatable {
    case empty
    case queued
    case running
    case stopping
    case attention(Int)
    case quietDone

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .queued: return "queued"
        case .running: return "running"
        case .stopping: return "stopping"
        case .attention: return "attention"
        case .quietDone: return "quiet_done"
        }
    }

    var kicker: String {
        switch self {
        case .empty: return "Medição"
        case .queued: return "Na fila"
        case .running: return "Ao vivo"
        case .stopping: return "Parando"
        case .attention: return "Atenção"
        case .quietDone: return "Encerrada"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem corridas publicadas"
        case .queued:
            return "medição na fila"
        case .running:
            return "medição ao vivo"
        case .stopping:
            return "medição parando"
        case .attention(let n):
            return n == 1 ? "1 corrida falhou" : "\(n) corridas falharam"
        case .quietDone:
            return "medição encerrada sem falhas publicadas"
        }
    }
}

// MARK: - Judgment

/// Pure Arena live control — rank · face · canStop · pack.
enum ArenaLiveControlJudgment {

    /// Lower = higher attention / list priority.
    static func statusRank(_ status: AtlasArenaRunStatus) -> Int {
        switch status {
        case .running: return 0
        case .stopping: return 1
        case .failed: return 2
        case .completed: return 3
        case .stopped: return 4
        case .queued: return 5
        case .unknown: return 6
        }
    }

    static func rank(_ runs: [AtlasArenaLiveRun]) -> [AtlasArenaLiveRun] {
        runs.enumerated().sorted { lhs, rhs in
            let lr = statusRank(lhs.element.status)
            let rr = statusRank(rhs.element.status)
            if lr != rr { return lr < rr }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func face(
        runs: [AtlasArenaLiveRun],
        primary: AtlasArenaLiveRun?
    ) -> ArenaLiveControlFace {
        if runs.isEmpty { return .empty }
        if runs.contains(where: { $0.status == .stopping })
            || primary?.status == .stopping {
            return .stopping
        }
        if runs.contains(where: { $0.status == .running })
            || primary?.status == .running {
            return .running
        }
        let failed = runs.filter { $0.status == .failed }.count
        if failed > 0 { return .attention(failed) }
        if runs.contains(where: { $0.status == .queued }) {
            return .queued
        }
        return .quietDone
    }

    static func canStop(primary: AtlasArenaLiveRun?) -> Bool {
        guard let primary else { return false }
        return primary.canStop == true && primary.measurementIdPublic != nil
    }

    static func packFacts(
        runs: [AtlasArenaLiveRun],
        primary: AtlasArenaLiveRun?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(runs: runs, primary: primary)
        facts.append("arena_live_face: \(face.productWord)")
        if runs.isEmpty {
            absences.append("nenhuma corrida publicada neste recorte")
            return (facts, absences)
        }
        facts.append("runs: \(runs.count)")
        facts.append("can_stop: \(canStop(primary: primary))")
        for run in rank(runs).prefix(6) {
            facts.append(
                "run: \(run.suite) · \(run.status.rawValue)"
            )
        }
        if let primary {
            facts.append("primary_suite: \(primary.suite)")
            facts.append("primary_status: \(primary.status.rawValue)")
        } else {
            absences.append("sem corrida primary publicada")
        }
        return (facts, absences)
    }

    // MARK: Measurement presentation (WAVE-187)

    /// Progress · primary line · alerts · narrative · execution live list.
    /// Never invents cases or report text.
    static func packMeasurementFacts(
        progress: AtlasArenaLiveProgress?,
        primary: AtlasArenaLiveRun?,
        alertSuiteCount: Int,
        narrative: String?,
        liveRuns: [AtlasArenaLiveRun],
        includeLiveList: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []

        if let progress {
            facts.append(
                "measurement_progress: \(progress.completed)/\(progress.total) (\(progress.remaining) restantes)"
            )
        } else {
            absences.append("progresso de casos não publicado neste recorte")
        }

        if let run = primary {
            facts.append(
                "measurement_primary: \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(ArenaRunStatusJudgment.productWord(for: run.status))"
            )
        } else {
            absences.append("corrida primary não publicada para medição")
        }

        facts.append(
            alertSuiteCount == 0
                ? "measurement_alerts: nenhuma exceção"
                : "measurement_alerts: \(alertSuiteCount) exceção(ões)"
        )

        if let narrative, !narrative.isEmpty {
            facts.append("measurement_narrative: \(narrative)")
        } else {
            absences.append("narrativa de relatório não publicada")
        }

        if includeLiveList {
            facts.append("measurement_live_runs: \(liveRuns.count)")
            let orderedLive = rank(liveRuns)
            for run in orderedLive.prefix(6) {
                facts.append(
                    "measurement_live: \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(ArenaRunStatusJudgment.productWord(for: run.status))"
                )
            }
            if liveRuns.isEmpty {
                absences.append("nenhuma corrida live publicada")
            }
        }

        return (facts, absences)
    }
}

// MARK: - ArenaNowJudgment

// MARK: - Types

/// Exclusive Arena Premium “agora” phase face (WAVE-066).
enum ArenaNowFace: Equatable {
    case preparing
    case idle
    case queued
    case running
    case stopping
    case stopped
    case completed
    case failed

    var productWord: String {
        switch self {
        case .preparing: return "preparing"
        case .idle: return "idle"
        case .queued: return "queued"
        case .running: return "running"
        case .stopping: return "stopping"
        case .stopped: return "stopped"
        case .completed: return "completed"
        case .failed: return "failed"
        }
    }

    var spokenFace: String {
        switch self {
        case .preparing: return "preparando a arena"
        case .idle: return "parada"
        case .queued: return "na fila"
        case .running: return "ao vivo"
        case .stopping: return "parando"
        case .stopped: return "parada pelo operador"
        case .completed: return "concluída"
        case .failed: return "interrompida"
        }
    }
}

/// Terminal chrome peel (title · subtitle · symbol · tone key).
struct ArenaNowTerminalChrome: Equatable {
    let title: String
    let subtitle: String
    let symbol: String
    let tone: ArenaPremiumTone
}

// MARK: - Judgment

/// Pure Arena now-phase grammar — face · terminal chrome · spoken · pack.
enum ArenaNowJudgment {

    static func face(
        loadPhase: LoadPhase,
        livePhase: AtlasArenaLivePhase?,
        compositeNil: Bool
    ) -> ArenaNowFace {
        if compositeNil {
            switch loadPhase {
            case .idle, .loading:
                return .preparing
            case .loaded, .failed:
                break
            }
        }
        switch livePhase ?? .idle {
        case .idle: return .idle
        case .queued: return .queued
        case .running: return .running
        case .stopping: return .stopping
        case .stopped: return .stopped
        case .completed: return .completed
        case .failed: return .failed
        }
    }

    static func face(from livePhase: AtlasArenaLivePhase) -> ArenaNowFace {
        switch livePhase {
        case .idle: return .idle
        case .queued: return .queued
        case .running: return .running
        case .stopping: return .stopping
        case .stopped: return .stopped
        case .completed: return .completed
        case .failed: return .failed
        }
    }

    static func face(terminal kind: ArenaPremiumTerminalKind) -> ArenaNowFace {
        switch kind {
        case .stopping: return .stopping
        case .stopped: return .stopped
        case .completed: return .completed
        case .failed: return .failed
        }
    }

    static func terminalChrome(_ kind: ArenaPremiumTerminalKind) -> ArenaNowTerminalChrome {
        switch kind {
        case .stopping:
            return ArenaNowTerminalChrome(
                title: "Parada solicitada",
                subtitle: "Finalizando o caso atual",
                symbol: "hourglass",
                tone: .active
            )
        case .stopped:
            return ArenaNowTerminalChrome(
                title: "Medição parada",
                subtitle: "Resultados parciais preservados",
                symbol: "stop.circle",
                tone: .neutral
            )
        case .completed:
            return ArenaNowTerminalChrome(
                title: "Medição concluída",
                subtitle: "Resultado terminal confirmado",
                symbol: "checkmark.seal",
                tone: .positive
            )
        case .failed:
            return ArenaNowTerminalChrome(
                title: "Medição interrompida",
                subtitle: "O que concluiu foi preservado",
                symbol: "exclamationmark.triangle",
                tone: .negative
            )
        }
    }

    static func idleKicker() -> String { "Arena pronta" }
    static func idleTitle() -> String { "Nada medindo agora" }
    static func idleBody() -> String {
        "Escolha os motores, as suítes e os braços. A Arena cuida da ordem e mostra apenas progresso confirmado."
    }

    static func queuedKicker() -> String { "Na fila" }
    static func queuedTitle() -> String { "Medição programada" }
    static func queuedHonestyLine() -> String {
        "Ainda não iniciado · nenhum progresso foi presumido."
    }

    static func preparingKicker() -> String { "Preparando a Arena" }
    static func preparingTitle() -> String { "Organizando as medições" }

    static func packFacts(
        loadPhase: LoadPhase,
        livePhase: AtlasArenaLivePhase?,
        compositeNil: Bool,
        engineTitle: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(
            loadPhase: loadPhase,
            livePhase: livePhase,
            compositeNil: compositeNil
        )
        facts.append("arena_now_face: \(face.productWord)")
        if let engineTitle, !engineTitle.isEmpty {
            facts.append("arena_engine_title: \(engineTitle)")
        }
        switch face {
        case .preparing:
            absences.append("composite ainda carregando")
        case .idle:
            absences.append("nenhuma medição ao vivo")
        case .queued:
            facts.append("arena_now_queue: true")
        case .running:
            facts.append("arena_now_live: true")
        case .stopping, .stopped, .completed, .failed:
            facts.append("arena_now_terminal: true")
        }
        return (facts, absences)
    }
}

// MARK: - ArenaScoreJudgment

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

// MARK: - ArenaStartJudgment

// MARK: - Types

/// Exclusive Arena start-submit face (WAVE-055).
enum ArenaStartSubmitFace: Equatable {
    case ready
    case missing([String])
    case noEngines
    case noSuites

    var productWord: String {
        switch self {
        case .ready: return "ready"
        case .missing: return "missing"
        case .noEngines: return "no_engines"
        case .noSuites: return "no_suites"
        }
    }

    var allowsSubmit: Bool {
        if case .ready = self { return true }
        return false
    }

    var spokenLabel: String {
        switch self {
        case .ready:
            return "rodar medição"
        case .noEngines:
            return "rodar medição indisponível, nenhum motor publicado"
        case .noSuites:
            return "rodar medição indisponível, nenhuma suite com adapter"
        case .missing(let fields):
            if fields.isEmpty { return "rodar medição indisponível" }
            return "rodar medição indisponível, falta \(fields.joined(separator: ", "))"
        }
    }

    var spokenHint: String {
        switch self {
        case .ready:
            return "envia medição governada ao servidor"
        case .noEngines:
            return "aguarde o servidor publicar pelo menos um motor"
        case .noSuites:
            return "aguarde o servidor publicar suite com adapter"
        case .missing:
            return "preencha ator, motivo, suites, motor e braços"
        }
    }
}

/// Exclusive start-receipt face after submit.
enum ArenaStartReceiptFace: Equatable {
    case absent
    case enqueued
    case workerGap
    case started
    case other(String)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .enqueued: return "enqueued"
        case .workerGap: return "worker_gap"
        case .started: return "started"
        case .other: return "other"
        }
    }

    var statusLine: String {
        switch self {
        case .absent:
            return ""
        case .enqueued:
            return "na fila, ainda não iniciado"
        case .workerGap:
            return "na fila · worker desligado"
        case .started:
            return "iniciado"
        case .other(let status):
            return status
        }
    }

    var spokenFace: String {
        switch self {
        case .absent:
            return "sem recibo de start"
        case .enqueued:
            return "recibo enfileirado, ainda não iniciado"
        case .workerGap:
            return "recibo enfileirado, worker de medição desligado no servidor"
        case .started:
            return "recibo, medição já iniciada"
        case .other(let status):
            return "recibo, status \(status)"
        }
    }
}

// MARK: - Judgment

/// Pure Arena start grammar — submit face · receipt face · pack · spoken.
enum ArenaStartJudgment {

    static let workerGapCopy =
        "worker de medição desligado no servidor — fila aguardando"
    static let newMeasurementLabel = "Nova medição"

    // MARK: Submit

    static func missingFields(input: AtlasArenaStartInput) -> [String] {
        var missing: [String] = []
        if input.operatorActor.isEmpty { missing.append("ator") }
        if input.operatorReason.isEmpty { missing.append("motivo auditável") }
        if input.suites.selectedValues.isEmpty { missing.append("suites") }
        if input.engine.isEmpty { missing.append("motor") }
        if input.arms.isEmpty { missing.append("braços") }
        return missing
    }

    static func submitFace(
        input: AtlasArenaStartInput,
        enginesEmpty: Bool,
        suitesEmpty: Bool
    ) -> ArenaStartSubmitFace {
        if enginesEmpty { return .noEngines }
        if suitesEmpty { return .noSuites }
        if input.isLocallyValidForSubmission { return .ready }
        return .missing(missingFields(input: input))
    }

    // MARK: Receipt

    static func receiptFace(
        _ receipt: AtlasArenaStartReceipt?
    ) -> ArenaStartReceiptFace {
        guard let receipt else { return .absent }
        // Worker gap elevates even when enqueued (operator must see server gap).
        if receipt.workerImplemented == false {
            return .workerGap
        }
        if receipt.started {
            return .started
        }
        if receipt.isEnqueued {
            return .enqueued
        }
        return .other(receipt.status)
    }

    static func receiptStatusLine(_ receipt: AtlasArenaStartReceipt) -> String {
        let face = receiptFace(receipt)
        if face.statusLine.isEmpty { return receipt.status }
        return face.statusLine
    }

    static func spokenReceipt(
        _ receipt: AtlasArenaStartReceipt,
        enginesCount: Int = 1,
        runsPlannedTotal: Int = 0
    ) -> String {
        var parts = ["recibo \(receipt.receiptHash)"]
        parts.append(receiptFace(receipt).spokenFace)
        if enginesCount > 1, runsPlannedTotal > 0 {
            parts.append("\(enginesCount) motores, \(runsPlannedTotal) runs na fila")
        }
        if receipt.workerImplemented == false {
            parts.append(workerGapCopy)
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Pack

    static func packFacts(
        input: AtlasArenaStartInput?,
        receipt: AtlasArenaStartReceipt?,
        enginesPublished: Int,
        suitesPublished: Int
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("engines_published: \(enginesPublished)")
        facts.append("suites_published: \(suitesPublished)")
        if let input {
            let face = submitFace(
                input: input,
                enginesEmpty: enginesPublished == 0,
                suitesEmpty: suitesPublished == 0
            )
            facts.append("arena_start_submit_face: \(face.productWord)")
            facts.append("arms: \(input.arms.map(\.rawValue).joined(separator: ","))")
            if !input.engine.isEmpty {
                facts.append("engine: \(input.engine)")
            }
        } else {
            absences.append("input de start não montado neste recorte")
        }
        let rFace = receiptFace(receipt)
        facts.append("arena_start_receipt_face: \(rFace.productWord)")
        if let receipt {
            facts.append("receipt_hash: \(receipt.receiptHash)")
            facts.append("runs_planned: \(receipt.runsPlanned)")
            facts.append("worker_implemented: \(receipt.workerImplemented)")
            if let mid = receipt.measurementIdPublic {
                facts.append("measurement_id: \(mid)")
            }
        } else {
            absences.append("sem recibo de start neste recorte")
        }
        return (facts, absences)
    }
}

// MARK: - ArenaSuiteJudgment

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
