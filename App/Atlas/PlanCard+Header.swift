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
            Spacer(minLength: 0)
            // C10 / cena 02: N/M só com checkpoint real — nunca 0/M fabricado.
            if let progress = bubble.executionProgress {
                Text("\(progress.current)/\(progress.total)")
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                    .accessibilityLabel(spokenProgressBadge(progress))
            }
        }
    }

    func auditTerminalLine(
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
}
