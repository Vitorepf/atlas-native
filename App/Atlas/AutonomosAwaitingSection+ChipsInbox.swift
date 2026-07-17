import SwiftUI
import AtlasCore

// Inbox chip — peel de AutonomosAwaitingSection+Chips.

extension AutonomosAwaitingYouSection {
    @ViewBuilder
    var awaitingInboxChip: some View {
        if !inboxDecisions.isEmpty {
            AutonomosDetailChipButton(
                label: "inbox \(inboxDecisions.count)",
                kind: .inbox,
                spokenLabel: inboxSpokenLabel(count: inboxDecisions.count),
                action: { onOpenDetail(.inbox) }
            )
        }
    }
}
