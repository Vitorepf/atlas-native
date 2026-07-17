import SwiftUI
import AtlasCore

// Chips inbox/ordens — peel de AutonomosAwaitingYouSection.

extension AutonomosAwaitingYouSection {
    @ViewBuilder
    var awaitingChips: some View {
        HStack(spacing: 8) {
            if !inboxDecisions.isEmpty {
                AutonomosDetailChipButton(
                    label: "inbox \(inboxDecisions.count)",
                    kind: .inbox,
                    spokenLabel: inboxSpokenLabel(count: inboxDecisions.count),
                    action: { onOpenDetail(.inbox) }
                )
            }
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
}
