import SwiftUI
import AtlasCore

// Spoken step — peel de PlanCard+A11y.
// ChipRow → PlanCard+A11yChipRow.swift

extension PlanCard {
    func spokenStep(
        step: AtlasExecutionPlan.Step,
        state: StepState,
        index: Int,
        total: Int
    ) -> String {
        var parts = ["passo \(index + 1) de \(total)", step.title]
        switch state {
        case .done: parts.append("concluído")
        case .current: parts.append("em curso")
        case .pending: parts.append("pendente")
        }
        return parts.joined(separator: ", ")
    }
}
