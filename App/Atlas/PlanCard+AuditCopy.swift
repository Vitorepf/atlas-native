import SwiftUI
import AtlasCore

// Linha visual da auditoria — peel de PlanCard+Audit.
// Status → PlanCard+AuditStatus.swift
// Caption → PlanCard+AuditCaption.swift

extension PlanCard {
    func auditTerminalCopy(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> some View {
        HStack(spacing: 6) {
            auditCaption
            Text("planejado \(plan.steps.count) · executado \(min(progress.current, progress.total))/\(progress.total)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            auditStatusWord(progress: progress)
        }
        .padding(.top, 2)
    }
}
