import SwiftUI
import AtlasCore

// Linha de passo do plano — peel de PlanCard+Steps (cena 02 residual honesty).

struct PlanStepRowView: View {
    let step: AtlasExecutionPlan.Step
    let index: Int
    let total: Int
    let state: PlanCard.StepState
    let isLast: Bool
    let spokenLabel: String
    let reduceMotion: Bool
    @State private var pulse = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(dotFill(state)).frame(width: 13, height: 13)
                        .opacity(state == .current && pulse && !reduceMotion ? 0.55 : 1)
                    if state == .done {
                        Image(systemName: "checkmark").font(.system(size: 7, weight: .bold))
                            .foregroundStyle(AtlasTheme.bg)
                    } else if state == .current {
                        Circle().fill(AtlasTheme.bg).frame(width: 5, height: 5)
                    }
                }
                .padding(.top, 2)
                if !isLast {
                    Rectangle().fill(AtlasTheme.accent.opacity(state == .pending ? 0.15 : 0.35))
                        .frame(width: 1.5).frame(maxHeight: .infinity)
                }
            }
            .frame(width: 13)
            .accessibilityHidden(true)

            Text(step.title)
                .font(.system(.caption))
                .foregroundStyle(state == .pending ? AtlasTheme.textTertiary
                                 : state == .current ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                .lineLimit(2)
                .padding(.bottom, isLast ? 0 : 9)
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

    private func dotFill(_ s: PlanCard.StepState) -> Color {
        switch s {
        case .done: return AtlasTheme.accent
        case .current: return AtlasTheme.accent
        case .pending: return AtlasTheme.separator
        }
    }
}
