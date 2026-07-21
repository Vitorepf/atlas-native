import Foundation
import AtlasCore

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
        switch status {
        case .running, .stopping, .queued: return .active
        case .completed: return .positive
        case .failed: return .negative
        case .stopped, .unknown, nil: return .neutral
        }
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
