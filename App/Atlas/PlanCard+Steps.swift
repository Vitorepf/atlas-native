import SwiftUI
import AtlasCore

// Steps list — peel de PlanCard.
// Detail chips → PlanCard+DetailChips.swift
// State → PlanCard+StepState.swift

extension PlanCard {
    enum StepState { case done, current, pending }

    func planStepsList(plan: AtlasExecutionPlan) -> some View {
        let total = plan.steps.count
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(plan.steps.enumerated()), id: \.element.id) { idx, step in
                let state = stepState(idx)
                PlanStepRowView(
                    step: step,
                    index: idx,
                    total: total,
                    state: state,
                    isLast: idx == total - 1,
                    spokenLabel: spokenStep(step: step, state: state, index: idx, total: total),
                    reduceMotion: reduceMotion
                )
            }
        }
        .accessibilityIdentifier(A11yID.planSteps)
    }
}
