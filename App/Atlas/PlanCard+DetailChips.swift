import SwiftUI
import AtlasCore

// Detail chips — peel de PlanCard+Steps.
// Agents → PlanCard+DetailChips+Agents.swift
// Tools → PlanCard+DetailChips+Tools.swift
// Gates → PlanCard+DetailChips+Gates.swift
// Chip row → PlanCard+ChipRow.swift

extension PlanCard {
    func planDetail(_ plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            planAgentsChips(plan)
            planToolsChips(plan)
            planGatesChips(plan)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(spokenPlanDetail(plan))
        .transition(reduceMotion ? .identity : .opacity)
    }
}
