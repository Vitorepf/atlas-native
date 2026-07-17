import SwiftUI
import AtlasCore

// Detail toggle ferramentas/agentes/gates — peel de PlanCard.

extension PlanCard {
    @ViewBuilder
    func planDetailSection(plan: AtlasExecutionPlan) -> some View {
        if !plan.tools.isEmpty || !plan.agents.isEmpty || !plan.qualityGates.isEmpty {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
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
}
