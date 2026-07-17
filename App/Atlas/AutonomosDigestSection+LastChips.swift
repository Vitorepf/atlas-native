import SwiftUI
import AtlasCore

// Chips do último digest — peel de AutonomosDigestSection+Last.
// Delivered → AutonomosDigestSection+LastChips+Delivered.swift
// Risks → AutonomosDigestSection+LastChips+Risks.swift
// Decisions → AutonomosDigestSection+LastChips+Decisions.swift

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestChips(_ digest: AtlasAutonomosDigestResponse) -> some View {
        HStack(spacing: 8) {
            lastDigestDeliveredChip(digest.last.counts.delivered)
            lastDigestRisksChip(digest.last.counts.risks)
            lastDigestDecisionsChip(digest.last.counts.pendingDecisions)
        }
        .animation(reduceMotion ? nil : .default, value: digest.last.counts.delivered)
        .animation(reduceMotion ? nil : .default, value: digest.last.counts.risks)
        .animation(reduceMotion ? nil : .default, value: digest.last.counts.pendingDecisions)
    }
}
