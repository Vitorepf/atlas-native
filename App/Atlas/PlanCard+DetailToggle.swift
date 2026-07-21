import SwiftUI
import AtlasCore

// Detail toggle ferramentas/agentes/gates — peel de PlanCard.
// Button → PlanCard+DetailToggle+Button.swift

extension PlanCard {
    @ViewBuilder
    func planDetailSection(plan: AtlasExecutionPlan) -> some View {
        if !plan.tools.isEmpty || !plan.agents.isEmpty || !plan.qualityGates.isEmpty {
            planDetailToggleButton(plan: plan)
            if showDetail { planDetail(plan) }
        }
    }
}
