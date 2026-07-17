import SwiftUI
import AtlasCore

// Steps ForEach — peel de PlanCard+Steps.

extension PlanCard {
    func planStepsRows(plan: AtlasExecutionPlan) -> some View {
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
    }
}
