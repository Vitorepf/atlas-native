import SwiftUI
import AtlasCore

// O PLANO da obra — o roteiro que o servidor computou (workflow, passos,
// ferramentas, agentes, gates). Antes ficava invisível; agora cada passo
// mostra done/atual/pendente a partir do checkpoint REAL (executionProgress).
// Sem plano no trace, o card não existe. Nada é inventado.
// Header → PlanCard+Header.swift · passos → PlanCard+Steps.swift · revisões → PlanCard+Revisions.swift.
struct PlanCard: View {
    let bubble: ChatBubble
    @Environment(AtlasSession.self) private var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var showDetail = false
    @State private var showRevisions = false

    var plan: AtlasExecutionPlan? { bubble.executionPlan }
    /// Checkpoint observado no stream; nil = nenhum passo marcado ainda (tudo pendente).
    var executionProgress: AtlasExecutionPlan.Progress? { bubble.executionProgress }
    var currentIndex: Int? { executionProgress?.current }
    var isTerminal: Bool { executionProgress?.isTerminal == true }
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
                planHeader(plan: plan)
                planStepsList(plan: plan)
                if session.auditModeEnabled, isTerminal, let progress = executionProgress {
                    auditTerminalLine(plan: plan, progress: progress)
                }
                // C19 / cena 02: "comparar versões" só com planRevisions reais.
                if !meaningfulRevisions.isEmpty {
                    revisionToggle(plan: plan)
                }
                if !plan.tools.isEmpty || !plan.agents.isEmpty || !plan.qualityGates.isEmpty {
                    Button {
                        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                            showDetail.toggle()
                        }
                    } label: {
                        Text(showDetail ? "menos" : "ferramentas · agentes · gates")
                            .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(showDetail ? "ocultar ferramentas agentes e gates" : "mostrar ferramentas agentes e gates")
                    .accessibilityHint(showDetail ? "toque para recolher" : "toque para expandir")
                    if showDetail { planDetail(plan) }
                }
            }
            .padding(12)
            .atlasCard(cornerRadius: 12, fillOpacity: 0.5)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(spokenCardLabel(plan: plan, progress: executionProgress))
            .accessibilityIdentifier(A11yID.planCard)
        }
    }

    @ViewBuilder
    private func revisionToggle(plan: AtlasExecutionPlan) -> some View {
        let count = meaningfulRevisions.count
        Button {
            if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                showRevisions.toggle()
            }
        } label: {
            Text(showRevisions ? "ocultar versões" : "comparar versões · \(count)")
                .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(spokenRevisionToggle(expanded: showRevisions, count: count))
        .accessibilityHint(showRevisions ? "toque para ocultar" : "toque para expandir")
        if showRevisions {
            PlanRevisionCompare(plan: plan, revisions: meaningfulRevisions)
                .transition(reduceMotion ? .identity : .opacity)
        }
    }
}
