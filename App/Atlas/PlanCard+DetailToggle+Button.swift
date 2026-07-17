import SwiftUI
import AtlasCore

// Toggle button — peel de PlanCard+DetailToggle.

extension PlanCard {
    @ViewBuilder
    func planDetailToggleButton(plan: AtlasExecutionPlan) -> some View {
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
    }
}
