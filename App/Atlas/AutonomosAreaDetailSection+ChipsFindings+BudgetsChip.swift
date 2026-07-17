import SwiftUI
import AtlasCore

// Budgets chip — peel de AutonomosAreaDetailSection+ChipsFindings.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    func backlogBudgetsChip() -> some View {
        AutonomosDetailChipButton(
            label: "budgets", kind: .budgets,
            spokenLabel: AutonomosAreaDetailA11y.spokenChip(kind: .budgets, count: 1)
        ) { onOpenDetail(.budgets) }
    }
}
