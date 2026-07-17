import SwiftUI
import AtlasCore

extension PlanCard {
    enum StepState { case done, current, pending }

    func planStepsList(plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(plan.steps.enumerated()), id: \.element.id) { idx, step in
                planStepRow(idx: idx, step: step, isLast: idx == plan.steps.count - 1)
            }
        }
    }

    @ViewBuilder
    func planStepRow(idx: Int, step: AtlasExecutionPlan.Step, isLast: Bool) -> some View {
        let state = stepState(idx)
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(dotFill(state)).frame(width: 13, height: 13)
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
            Text(step.title)
                .font(.system(.caption))
                .foregroundStyle(state == .pending ? AtlasTheme.textTertiary
                                 : state == .current ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                .lineLimit(2)
                .padding(.bottom, isLast ? 0 : 9)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(planStepAccessibility(step: step, state: state))
    }

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
        .transition(reduceMotion ? .identity : .opacity)
    }

    func stepState(_ idx: Int) -> StepState {
        guard let c = currentIndex else { return .pending }
        if isTerminal { return .done }
        if idx + 1 < c { return .done }
        if idx + 1 == c { return .current }
        return .pending
    }

    private func planStepAccessibility(step: AtlasExecutionPlan.Step, state: StepState) -> String {
        let word: String
        switch state {
        case .done: word = "concluído"
        case .current: word = "em curso"
        case .pending: word = "pendente"
        }
        return "\(step.title), \(word)"
    }

    private func dotFill(_ s: StepState) -> Color {
        switch s {
        case .done: return AtlasTheme.accent
        case .current: return AtlasTheme.accent
        case .pending: return AtlasTheme.separator
        }
    }

    private func chipRow(label: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(AtlasFont.mono(9)).tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
            PlanFlowChips(items: items)
        }
    }
}
