import SwiftUI
import AtlasCore

// Steps list — peel de PlanCard.
// Detail chips → PlanCard+DetailChips.swift
// State → PlanCard+StepState.swift
// Rows → PlanCard+StepsRows.swift

extension PlanCard {
    enum StepState { case done, current, pending }

    func planStepsList(plan: AtlasExecutionPlan) -> some View {
        planStepsRows(plan: plan)
            .accessibilityIdentifier(A11yID.planSteps)
    }
}
