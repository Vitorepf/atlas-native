import SwiftUI
import AtlasCore

// A11y e spoken labels — peel de PlanCard (cena 02 residual honesty).

extension PlanCard {
    func spokenCardLabel(plan: AtlasExecutionPlan, progress: AtlasExecutionPlan.Progress?) -> String {
        var parts = ["plano da obra, \(plan.title), \(plan.steps.count) passos"]
        if let progress {
            parts.append("checkpoint \(progress.current) de \(progress.total), \(progress.title)")
            if progress.isTerminal { parts.append("concluído") }
        }
        return parts.joined(separator: ", ")
    }

    func spokenProgressBadge(_ progress: AtlasExecutionPlan.Progress) -> String {
        "\(progress.current) de \(progress.total) passos, \(progress.title)"
    }

    func spokenRevisionToggle(expanded: Bool, count: Int) -> String {
        expanded
            ? "comparar versões do plano, expandido, \(count) versões"
            : "comparar versões do plano, \(count) versões"
    }
}
