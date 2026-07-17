import SwiftUI
import AtlasCore

// Detail chips — peel de PlanCard+Steps.
// Chip row → PlanCard+ChipRow.swift

extension PlanCard {
    func planDetail(_ plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            if !plan.agents.isEmpty {
                chipRow(label: "agentes", items: plan.agents.map(\.title))
            }
            if !plan.tools.isEmpty {
                chipRow(label: "ferramentas", items: plan.tools.map(\.label))
            }
            if !plan.qualityGates.isEmpty {
                chipRow(label: "gates", items: plan.qualityGates.map(\.label))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(spokenPlanDetail(plan))
        .transition(reduceMotion ? .identity : .opacity)
    }
}
