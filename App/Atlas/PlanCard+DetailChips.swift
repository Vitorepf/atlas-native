import SwiftUI
import AtlasCore

// Detail chips — peel de PlanCard+Steps.

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

    func chipRow(label: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(AtlasFont.mono(9)).tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            PlanFlowChips(items: items)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenChipRow(label: label, items: items))
    }
}
