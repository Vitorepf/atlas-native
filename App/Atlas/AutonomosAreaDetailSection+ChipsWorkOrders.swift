import SwiftUI
import AtlasCore

// Work orders chip — peel de AutonomosAreaDetailSection+ShortcutChips.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    func backlogWorkOrdersChip(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailChipButton(
            label: "workOrders \(backlog.workOrders.count)", kind: .workOrders,
            spokenLabel: AutonomosAreaDetailA11y.spokenChip(kind: .workOrders, count: backlog.workOrders.count)
        ) { onOpenDetail(.workOrders) }
    }
}
