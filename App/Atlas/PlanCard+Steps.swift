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
            FlowChips(items: items)
        }
    }
}

// Quebra chips em linhas conforme a largura (agentes/ferramentas/gates).
private struct FlowChips: View {
    let items: [String]
    var body: some View {
        FlexWrap(spacing: 6, lineSpacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textSecondary)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
                    .lineLimit(1)
            }
        }
    }
}

// Layout que envolve os filhos em múltiplas linhas (sem dependência externa).
private struct FlexWrap: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += lineHeight + lineSpacing; lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += lineHeight + lineSpacing; lineHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
