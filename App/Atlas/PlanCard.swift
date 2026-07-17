import SwiftUI
import AtlasCore

// O PLANO da obra — o roteiro que o servidor computou (workflow, passos,
// ferramentas, agentes, gates). Antes ficava invisível; agora cada passo
// mostra done/atual/pendente a partir do checkpoint REAL (executionProgress).
// Sem plano no trace, o card não existe. Nada é inventado.
// Header → +Header · Steps → +Steps · Body → +Body · Revisions → +Revisions
// Progress → PlanCard+Progress.swift
struct PlanCard: View {
    let bubble: ChatBubble
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var showDetail = false
    @State var showRevisions = false

    var body: some View {
        if let plan, !plan.steps.isEmpty {
            VStack(alignment: .leading, spacing: 9) {
                planBody(plan: plan)
            }
            .padding(12)
            .atlasCard(cornerRadius: 12, fillOpacity: 0.5)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(spokenCardLabel(plan: plan, progress: executionProgress))
            .accessibilityIdentifier(A11yID.planCard)
        }
    }
}
