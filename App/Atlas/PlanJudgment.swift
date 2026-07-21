import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive plan progress face (WAVE-040).
enum PlanProgressFace: Equatable {
    /// No plan on the bubble.
    case absent
    /// Plan published; no progress checkpoint yet.
    case pending(steps: Int)
    /// Progress published; not terminal.
    case running(current: Int, total: Int, title: String)
    /// Progress terminal.
    case terminal(current: Int, total: Int, title: String)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .pending: return "pending"
        case .running: return "running"
        case .terminal: return "terminal"
        }
    }

    var kicker: String {
        switch self {
        case .absent: return "Plano"
        case .pending: return "Plano sem checkpoint"
        case .running: return "Plano em curso"
        case .terminal: return "Plano terminal"
        }
    }

    var spokenFace: String {
        switch self {
        case .absent:
            return "sem plano de execução publicado"
        case .pending(let steps):
            return steps == 1
                ? "plano com 1 passo, nenhum checkpoint observado"
                : "plano com \(steps) passos, nenhum checkpoint observado"
        case .running(let current, let total, let title):
            return "plano em curso, checkpoint \(current) de \(total), \(title)"
        case .terminal(let current, let total, let title):
            return "plano terminal, \(current) de \(total), \(title)"
        }
    }
}

/// Step lifecycle for plan rows — pure, not View-owned.
enum PlanStepState: Equatable {
    case done
    case current
    case pending

    var productWord: String {
        switch self {
        case .done: return "done"
        case .current: return "current"
        case .pending: return "pending"
        }
    }

    var spoken: String {
        switch self {
        case .done: return "concluído"
        case .current: return "em curso"
        case .pending: return "pendente"
        }
    }
}

// MARK: - Judgment

/// Pure plan progress grammar — face · step · pack · spoken.
enum PlanJudgment {

    // MARK: Face

    static func face(
        plan: AtlasExecutionPlan?,
        progress: AtlasExecutionPlan.Progress?
    ) -> PlanProgressFace {
        // Progress alone is honest (cockpit may publish checkpoint without full plan).
        if let progress {
            if progress.isTerminal {
                return .terminal(
                    current: progress.current,
                    total: progress.total,
                    title: progress.title
                )
            }
            return .running(
                current: progress.current,
                total: progress.total,
                title: progress.title
            )
        }
        guard let plan, !plan.steps.isEmpty else { return .absent }
        return .pending(steps: plan.steps.count)
    }

    static func face(bubble: ChatBubble) -> PlanProgressFace {
        face(plan: bubble.executionPlan, progress: bubble.executionProgress)
    }

    // MARK: Step state

    /// 1-based checkpoint semantics: idx 0 is step 1.
    static func stepState(
        index: Int,
        progress: AtlasExecutionPlan.Progress?,
        isTerminal: Bool
    ) -> PlanStepState {
        guard let progress else { return .pending }
        if isTerminal || progress.isTerminal { return .done }
        let c = progress.current
        if index + 1 < c { return .done }
        if index + 1 == c { return .current }
        return .pending
    }

    static func stepState(
        index: Int,
        plan: AtlasExecutionPlan?,
        progress: AtlasExecutionPlan.Progress?
    ) -> PlanStepState {
        let terminal = progress?.isTerminal == true
        return stepState(index: index, progress: progress, isTerminal: terminal)
    }

    // MARK: Summary

    /// Shared card + cockpit line: never invent title when progress nil.
    static func summaryLine(
        plan: AtlasExecutionPlan?,
        progress: AtlasExecutionPlan.Progress?
    ) -> String {
        switch face(plan: plan, progress: progress) {
        case .absent:
            return "sem plano publicado"
        case .pending(let steps):
            return steps == 1 ? "1 passo · sem checkpoint" : "\(steps) passos · sem checkpoint"
        case .running(let current, let total, let title):
            return "\(current)/\(total) · \(title)"
        case .terminal(let current, let total, let title):
            return "\(current)/\(total) · \(title) · terminal"
        }
    }

    static func summaryLine(bubble: ChatBubble) -> String {
        summaryLine(plan: bubble.executionPlan, progress: bubble.executionProgress)
    }

    static func progressBadge(_ progress: AtlasExecutionPlan.Progress) -> String {
        "\(progress.current)/\(progress.total)"
    }

    static func spokenProgressBadge(_ progress: AtlasExecutionPlan.Progress) -> String {
        "\(progress.current) de \(progress.total) passos, \(progress.title)"
    }

    // MARK: Spoken card

    static func spokenCard(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress?
    ) -> String {
        var parts = ["plano da obra, \(plan.title), \(plan.steps.count) passos"]
        parts.append(face(plan: plan, progress: progress).spokenFace)
        return parts.joined(separator: ", ")
    }

    static func spokenRevisionGroup(label: String, stepCount: Int) -> String {
        let noun = stepCount == 1 ? "passo" : "passos"
        return "\(label), \(stepCount) \(noun)"
    }

    static func spokenStep(
        step: AtlasExecutionPlan.Step,
        state: PlanStepState,
        index: Int,
        total: Int
    ) -> String {
        ["passo \(index + 1) de \(total)", step.title, state.spoken]
            .joined(separator: ", ")
    }

    static func spokenAuditTerminal(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> String {
        let executed = min(progress.current, progress.total)
        return "auditoria do plano, \(plan.steps.count) passos planejados, \(executed) de \(progress.total) executados, \(progress.isTerminal ? "terminal" : "em curso")"
    }

    // MARK: Pack

    static func packFacts(
        plan: AtlasExecutionPlan?,
        progress: AtlasExecutionPlan.Progress?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(plan: plan, progress: progress)
        facts.append("plan_face: \(face.productWord)")
        guard let plan, !plan.steps.isEmpty else {
            absences.append("plano de execução não publicado neste recorte")
            return (facts, absences)
        }
        facts.append("plan_title: \(plan.title)")
        facts.append("plan_steps: \(plan.steps.count)")
        facts.append(summaryLine(plan: plan, progress: progress))
        if let progress {
            facts.append("progress_current: \(progress.current)")
            facts.append("progress_total: \(progress.total)")
            facts.append("progress_title: \(progress.title)")
            facts.append("progress_terminal: \(progress.isTerminal)")
        } else {
            absences.append("nenhum checkpoint de progresso observado")
        }
        if !plan.agents.isEmpty {
            facts.append("agents: " + plan.agents.map(\.title).joined(separator: ", "))
        } else {
            absences.append("sem agentes no plano publicado")
        }
        if !plan.tools.isEmpty {
            facts.append("tools: " + plan.tools.map(\.label).joined(separator: ", "))
        }
        if !plan.qualityGates.isEmpty {
            facts.append("gates: " + plan.qualityGates.map(\.label).joined(separator: ", "))
        }
        return (facts, absences)
    }
}
