import SwiftUI
import AtlasCore

// Spoken detail/audit/revision — peel de PlanCard+A11y.

extension PlanCard {
    func spokenPlanDetail(_ plan: AtlasExecutionPlan) -> String {
        var parts: [String] = []
        if !plan.agents.isEmpty { parts.append("agentes, \(plan.agents.map(\.title).joined(separator: ", "))") }
        if !plan.tools.isEmpty { parts.append("ferramentas, \(plan.tools.map(\.label).joined(separator: ", "))") }
        if !plan.qualityGates.isEmpty { parts.append("gates, \(plan.qualityGates.map(\.label).joined(separator: ", "))") }
        return parts.joined(separator: ", ")
    }

    func spokenAuditTerminal(plan: AtlasExecutionPlan, progress: AtlasExecutionPlan.Progress) -> String {
        "auditoria do plano, \(plan.steps.count) passos planejados, \(min(progress.current, progress.total)) de \(progress.total) executados, \(progress.isTerminal ? "terminal" : "em curso")"
    }

    func spokenRevisionToggle(expanded: Bool, count: Int) -> String {
        expanded
            ? "comparar versões do plano, expandido, \(count) versões"
            : "comparar versões do plano, \(count) versões"
    }
}
