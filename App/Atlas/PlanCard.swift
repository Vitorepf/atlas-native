import SwiftUI
import AtlasCore

// O PLANO da obra — o roteiro que o servidor computou (workflow, passos,
// ferramentas, agentes, gates). Antes ficava invisível; agora cada passo
// mostra done/atual/pendente a partir do checkpoint REAL (executionProgress).
// Sem plano no trace, o card não existe. Nada é inventado.
// Revisões → PlanCard+Revisions.swift.
struct PlanCard: View {
    let bubble: ChatBubble
    @Environment(AtlasSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showDetail = false
    @State private var showRevisions = false

    private var plan: AtlasExecutionPlan? { bubble.executionPlan }
    // Índice 1-based do passo atual; nil = plano sem checkpoint observado ainda.
    private var currentIndex: Int? { bubble.executionProgress?.current }
    private var isTerminal: Bool { bubble.executionProgress?.isTerminal == true }
    private var revisions: [AtlasTraceGovernance.PlanRevision] { bubble.planRevisions }
    /// Só revisões com metadata real do servidor — ausência não vira “v1” nem motivo genérico.
    private var meaningfulRevisions: [AtlasTraceGovernance.PlanRevision] {
        revisions.filter { rev in
            rev.reason?.isEmpty == false || rev.archivedAt != nil || !rev.stepTitles.isEmpty
        }
    }

    var body: some View {
        if let plan, !plan.steps.isEmpty {
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 12)).foregroundStyle(AtlasTheme.accent.opacity(0.85))
                    Text(plan.title)
                        .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    Spacer(minLength: 0)
                    if let c = currentIndex {
                        Text("\(min(c, plan.steps.count))/\(plan.steps.count)")
                            .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
                            .monospacedDigit()
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(plan.steps.enumerated()), id: \.element.id) { idx, step in
                        planStepRow(idx: idx, step: step, isLast: idx == plan.steps.count - 1)
                    }
                }
                if session.auditModeEnabled, isTerminal, let progress = bubble.executionProgress {
                    auditTerminalLine(plan: plan, progress: progress)
                }
                // C19 / cena 02: "comparar versões" só com planRevisions reais.
                if !meaningfulRevisions.isEmpty {
                    Button {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                            showRevisions.toggle()
                        }
                    } label: {
                        Text(showRevisions
                             ? "ocultar versões"
                             : "comparar versões · \(meaningfulRevisions.count)")
                            .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("comparar versões do plano")
                    if showRevisions {
                        PlanRevisionCompare(plan: plan, revisions: meaningfulRevisions)
                            .transition(reduceMotion ? .identity : .opacity)
                    }
                }
                if !plan.tools.isEmpty || !plan.agents.isEmpty || !plan.qualityGates.isEmpty {
                    Button {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                            showDetail.toggle()
                        }
                    } label: {
                        Text(showDetail ? "menos" : "ferramentas · agentes · gates")
                            .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .buttonStyle(.plain)
                    if showDetail { planDetail(plan) }
                }
            }
            .padding(12)
            .atlasCard(cornerRadius: 12, fillOpacity: 0.5)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("plano da obra, \(plan.steps.count) passos")
        }
    }

    @ViewBuilder
    private func planStepRow(idx: Int, step: AtlasExecutionPlan.Step, isLast: Bool) -> some View {
        // done: índice já ultrapassado; current: exatamente o atual; pending: futuro.
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

    private func planStepAccessibility(step: AtlasExecutionPlan.Step, state: StepState) -> String {
        let word: String
        switch state {
        case .done: word = "concluído"
        case .current: word = "em curso"
        case .pending: word = "pendente"
        }
        return "\(step.title), \(word)"
    }

    private enum StepState { case done, current, pending }

    private func stepState(_ idx: Int) -> StepState {
        guard let c = currentIndex else { return .pending }
        if isTerminal { return .done }
        if idx + 1 < c { return .done }
        if idx + 1 == c { return .current }
        return .pending
    }

    private func dotFill(_ s: StepState) -> Color {
        switch s {
        case .done: return AtlasTheme.accent
        case .current: return AtlasTheme.accent
        case .pending: return AtlasTheme.separator
        }
    }

    private func planDetail(_ plan: AtlasExecutionPlan) -> some View {
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

    private func auditTerminalLine(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> some View {
        HStack(spacing: 6) {
            Text("AUDITORIA")
                .font(AtlasFont.mono(9))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.domOperacional)
            Text("planejado \(plan.steps.count) · executado \(min(progress.current, progress.total))/\(progress.total)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
            Spacer(minLength: 0)
            Text(progress.isTerminal ? "terminal" : "em curso")
                .font(AtlasFont.mono(9))
                .foregroundStyle(progress.isTerminal ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
        }
        .padding(.top, 2)
        .accessibilityLabel("auditoria do plano, \(plan.steps.count) passos planejados, \(min(progress.current, progress.total)) de \(progress.total) executados")
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
