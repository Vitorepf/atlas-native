import SwiftUI
import AtlasCore

// Backlog chip row — peel de AutonomosAreaDetailSection+Shortcuts.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    func backlogChipRow(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        HStack(spacing: 8) {
            AutonomosDetailChipButton(
                label: "workOrders \(backlog.workOrders.count)", kind: .workOrders,
                spokenLabel: AutonomosAreaDetailA11y.spokenChip(kind: .workOrders, count: backlog.workOrders.count)
            ) { onOpenDetail(.workOrders) }
            AutonomosDetailChipButton(
                label: "inbox \(backlog.inboxItems.count)", kind: .inbox,
                spokenLabel: AutonomosAreaDetailA11y.spokenChip(kind: .inbox, count: backlog.inboxItems.count)
            ) { onOpenDetail(.inbox) }
            AutonomosDetailChipButton(
                label: "findings \(backlog.findings.returned)", kind: .findings,
                spokenLabel: AutonomosAreaDetailA11y.spokenChip(kind: .findings, count: backlog.findings.returned)
            ) { onOpenDetail(.findings) }
            AutonomosDetailChipButton(
                label: "budgets", kind: .budgets,
                spokenLabel: AutonomosAreaDetailA11y.spokenChip(kind: .budgets, count: 1)
            ) { onOpenDetail(.budgets) }
        }
    }
}
