import SwiftUI
import AtlasCore

// A11y e spoken labels do PlanCard.
// Peel forest fused cycle 018 (card/step/chip/progress/detail spoken peels).

extension PlanCard {
    func spokenCardLabel(plan: AtlasExecutionPlan, progress: AtlasExecutionPlan.Progress?) -> String {
        var parts = ["plano da obra, \(plan.title), \(plan.steps.count) passos"]
        if let progress {
            parts.append("checkpoint \(progress.current) de \(progress.total), \(progress.title)")
            if progress.isTerminal { parts.append("concluído") }
        } else {
            parts.append("nenhum checkpoint observado, passos pendentes")
        }
        return parts.joined(separator: ", ")
    }

    func spokenStep(
        step: AtlasExecutionPlan.Step,
        state: StepState,
        index: Int,
        total: Int
    ) -> String {
        var parts = ["passo \(index + 1) de \(total)", step.title]
        parts.append(Self.spokenStepState(state))
        return parts.joined(separator: ", ")
    }

    static func spokenStepState(_ state: StepState) -> String {
        switch state {
        case .done: "concluído"
        case .current: "em curso"
        case .pending: "pendente"
        }
    }

    func spokenChipRow(label: String, items: [String]) -> String {
        "\(label), \(items.count) itens, \(items.joined(separator: ", "))"
    }

    func spokenProgressBadge(_ progress: AtlasExecutionPlan.Progress) -> String {
        "\(progress.current) de \(progress.total) passos, \(progress.title)"
    }

    func spokenAuditTerminal(plan: AtlasExecutionPlan, progress: AtlasExecutionPlan.Progress) -> String {
        "auditoria do plano, \(plan.steps.count) passos planejados, \(min(progress.current, progress.total)) de \(progress.total) executados, \(progress.isTerminal ? "terminal" : "em curso")"
    }

    func spokenPlanDetail(_ plan: AtlasExecutionPlan) -> String {
        var parts: [String] = []
        if !plan.agents.isEmpty { parts.append("agentes, \(plan.agents.map(\.title).joined(separator: ", "))") }
        if !plan.tools.isEmpty { parts.append("ferramentas, \(plan.tools.map(\.label).joined(separator: ", "))") }
        if !plan.qualityGates.isEmpty { parts.append("gates, \(plan.qualityGates.map(\.label).joined(separator: ", "))") }
        return parts.joined(separator: ", ")
    }

    func spokenRevisionToggle(expanded: Bool, count: Int) -> String {
        expanded
            ? "comparar versões do plano, expandido, \(count) versões"
            : "comparar versões do plano, \(count) versões"
    }
}
