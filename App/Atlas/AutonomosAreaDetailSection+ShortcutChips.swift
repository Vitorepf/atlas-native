import SwiftUI
import AtlasCore

// Backlog chip row — peel de AutonomosAreaDetailSection+Shortcuts.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    func backlogChipRow(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        HStack(spacing: 8) {
            backlogWorkOrdersChip(backlog)
            backlogInboxChip(backlog)
            backlogFindingsChip(backlog)
            backlogBudgetsChip()
        }
    }
}
