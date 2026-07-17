import SwiftUI
import AtlasCore

// Findings + budgets chips — peel de AutonomosAreaDetailSection+ShortcutChips.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    func backlogFindingsChip(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailChipButton(
            label: "findings \(backlog.findings.returned)", kind: .findings,
            spokenLabel: AutonomosAreaDetailA11y.spokenChip(kind: .findings, count: backlog.findings.returned)
        ) { onOpenDetail(.findings) }
    }

    @ViewBuilder
    func backlogBudgetsChip() -> some View {
        AutonomosDetailChipButton(
            label: "budgets", kind: .budgets,
            spokenLabel: AutonomosAreaDetailA11y.spokenChip(kind: .budgets, count: 1)
        ) { onOpenDetail(.budgets) }
    }
}
