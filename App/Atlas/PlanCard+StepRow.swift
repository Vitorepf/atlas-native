import SwiftUI
import AtlasCore

// Linha de passo do plano — peel de PlanCard+Steps (cena 02 residual honesty).
// Dot → PlanCard+StepRowDot.swift
// Title → PlanCard+StepRowTitle.swift
// Pulse → PlanCard+StepRowPulse.swift
// A11y → PlanCard+StepRowA11y.swift
// Body → PlanCard+StepRow+Body.swift

struct PlanStepRowView: View {
    let step: AtlasExecutionPlan.Step
    let index: Int
    let total: Int
    let state: PlanCard.StepState
    let isLast: Bool
    let spokenLabel: String
    let reduceMotion: Bool
    @State var pulse = false

    var body: some View {
        stepRowBody
    }
}
