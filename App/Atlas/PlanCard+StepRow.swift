import SwiftUI
import AtlasCore

// Linha de passo do plano — peel de PlanCard+Steps (cena 02 residual honesty).
// Dot → PlanCard+StepRowDot.swift
// Title → PlanCard+StepRowTitle.swift

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
        HStack(alignment: .top, spacing: 10) {
            stepDotColumn
            stepTitleColumn
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
        .accessibilityAddTraits(state == .current ? .isSelected : [])
        .accessibilityIdentifier(A11yID.planStep(index))
        .onAppear {
            if state == .current && !reduceMotion {
                withAnimation(AtlasMotion.breath(0.9)) { pulse = true }
            }
        }
        .onChange(of: state == .current) { _, now in if !now { pulse = false } }
    }
}
