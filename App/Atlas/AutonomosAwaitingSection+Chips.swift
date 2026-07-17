import SwiftUI
import AtlasCore

// Chips inbox/ordens — peel de AutonomosAwaitingYouSection.

extension AutonomosAwaitingYouSection {
    @ViewBuilder
    var awaitingChips: some View {
        HStack(spacing: 8) {
            awaitingInboxChip
            awaitingWorkOrdersChip
        }
    }
}
