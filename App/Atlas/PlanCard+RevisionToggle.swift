import SwiftUI
import AtlasCore

// Toggle de revisões C19 — peel de PlanCard.

extension PlanCard {
    @ViewBuilder
    func revisionToggle(plan: AtlasExecutionPlan) -> some View {
        let count = meaningfulRevisions.count
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
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
