import SwiftUI
import AtlasCore

extension PlanCard {
    func planHeader(plan: AtlasExecutionPlan) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 12)).foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .accessibilityHidden(true)
            Text(plan.title)
                .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(plan.title)
            Spacer(minLength: 0)
            // C10 / cena 02: N/M só com checkpoint real — nunca 0/M fabricado.
            if let progress = bubble.executionProgress {
                Text("\(progress.current)/\(progress.total)")
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                    .accessibilityLabel(spokenProgressBadge(progress))
                    .accessibilityIdentifier(A11yID.planProgress)
            }
        }
        .accessibilityElement(children: .contain)
    }
}
