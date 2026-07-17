import SwiftUI
import AtlasCore

// Work orders chip — peel de AutonomosAwaitingSection+Chips.

extension AutonomosAwaitingYouSection {
    @ViewBuilder
    var awaitingWorkOrdersChip: some View {
        if !workOrderDecisions.isEmpty {
            AutonomosDetailChipButton(
                label: "ordens \(workOrderDecisions.count)",
                kind: .workOrders,
                spokenLabel: workOrdersSpokenLabel(count: workOrderDecisions.count),
                action: { onOpenDetail(.workOrders) }
            )
        }
    }
}
