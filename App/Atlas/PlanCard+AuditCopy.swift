import SwiftUI
import AtlasCore

// Linha visual da auditoria — peel de PlanCard+Audit.
// Status → PlanCard+AuditStatus.swift
// Caption → PlanCard+AuditCaption.swift
// ProgressLine → PlanCard+AuditCopy+ProgressLine.swift

extension PlanCard {
    func auditTerminalCopy(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> some View {
        HStack(spacing: 6) {
            auditCaption
            auditProgressLine(plan: plan, progress: progress)
            Spacer(minLength: 0)
            auditStatusWord(progress: progress)
        }
        .padding(.top, 2)
    }
}
