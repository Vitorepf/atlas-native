import SwiftUI
import AtlasCore

// O PLANO da obra — o roteiro que o servidor computou (workflow, passos,
// ferramentas, agentes, gates). Antes ficava invisível; agora cada passo
// mostra done/atual/pendente a partir do checkpoint REAL (executionProgress).
// Sem plano no trace, o card não existe. Nada é inventado.
// Header → +Header · Steps → +Steps · Body → +Body · Revisions → +Revisions
// Progress → PlanCard+Progress.swift
// Chrome → PlanCard+Chrome.swift
struct PlanCard: View {
    let bubble: ChatBubble
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var showDetail = false
    @State var showRevisions = false

    var body: some View {
        if let plan, !plan.steps.isEmpty {
            planCardChrome(plan: plan) {
                VStack(alignment: .leading, spacing: 9) {
                    planBody(plan: plan)
                }
            }
        }
    }
}
