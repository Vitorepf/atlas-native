import SwiftUI
import AtlasCore

// Chips do último digest — peel de AutonomosDigestSection+Last.
// Delivered → AutonomosDigestSection+LastChips+Delivered.swift
// Risks → AutonomosDigestSection+LastChips+Risks.swift
// Decisions → AutonomosDigestSection+LastChips+Decisions.swift
// Motion → AutonomosDigestSection+LastChips+Motion.swift

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestChips(_ digest: AtlasAutonomosDigestResponse) -> some View {
        lastDigestChipsMotion(
            HStack(spacing: 8) {
                lastDigestDeliveredChip(digest.last.counts.delivered)
                lastDigestRisksChip(digest.last.counts.risks)
                lastDigestDecisionsChip(digest.last.counts.pendingDecisions)
            },
            counts: digest.last.counts
        )
    }
}
