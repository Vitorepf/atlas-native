import SwiftUI
import AtlasCore

// A11y e spoken labels — peel de PlanCard (cena 02 residual honesty).
// Detail/audit → PlanCard+A11yDetail.swift

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

    func spokenProgressBadge(_ progress: AtlasExecutionPlan.Progress) -> String {
        "\(progress.current) de \(progress.total) passos, \(progress.title)"
    }

    func spokenStep(
        step: AtlasExecutionPlan.Step,
        state: StepState,
        index: Int,
        total: Int
    ) -> String {
        var parts = ["passo \(index + 1) de \(total)", step.title]
        switch state {
        case .done: parts.append("concluído")
        case .current: parts.append("em curso")
        case .pending: parts.append("pendente")
        }
        return parts.joined(separator: ", ")
    }

    func spokenChipRow(label: String, items: [String]) -> String {
        "\(label), \(items.count) itens, \(items.joined(separator: ", "))"
    }
}
