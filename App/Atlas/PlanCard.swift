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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showDetail = false
    @State private var showRevisions = false

    var plan: AtlasExecutionPlan? { bubble.executionPlan }
    // Índice 1-based do passo atual; nil = plano sem checkpoint observado ainda.
    var currentIndex: Int? { bubble.executionProgress?.current }
    var isTerminal: Bool { bubble.executionProgress?.isTerminal == true }
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
}
