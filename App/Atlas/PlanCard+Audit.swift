import SwiftUI
import AtlasCore

// Auditoria terminal — peel de PlanCard+Header.

extension PlanCard {
    func auditTerminalLine(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> some View {
        HStack(spacing: 6) {
            Text("AUDITORIA")
                .font(AtlasFont.mono(9))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
            Text("planejado \(plan.steps.count) · executado \(min(progress.current, progress.total))/\(progress.total)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            Text(progress.isTerminal ? "terminal" : "em curso")
                .font(AtlasFont.mono(9))
                .foregroundStyle(progress.isTerminal ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.top, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenAuditTerminal(plan: plan, progress: progress))
        .accessibilityAddTraits(.isStaticText)
    }
}
