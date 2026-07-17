import SwiftUI
import AtlasCore

// Spoken step — peel de PlanCard+A11y.
// ChipRow → PlanCard+A11yChipRow.swift · State → PlanCard+A11yStepState.swift

extension PlanCard {
    func spokenStep(
        step: AtlasExecutionPlan.Step,
        state: StepState,
        index: Int,
        total: Int
    ) -> String {
        var parts = ["passo \(index + 1) de \(total)", step.title]
        parts.append(Self.spokenStepState(state))
        return parts.joined(separator: ", ")
    }
}
