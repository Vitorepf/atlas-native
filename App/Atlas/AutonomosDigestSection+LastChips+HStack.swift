import SwiftUI
import AtlasCore

// Chips HStack — peel de AutonomosDigestSection+LastChips.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestChipsRow(_ counts: AtlasAutonomosDigestCounts) -> some View {
        HStack(spacing: 8) {
            lastDigestDeliveredChip(counts.delivered)
            lastDigestRisksChip(counts.risks)
            lastDigestDecisionsChip(counts.pendingDecisions)
        }
    }
}
