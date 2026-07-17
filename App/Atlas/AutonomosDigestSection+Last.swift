import SwiftUI
import AtlasCore

// Corpo do último digest — peel de AutonomosDigestSection (régua ≤100).
// Predicates → AutonomosDigestSection+Predicates.swift
// Chips → AutonomosDigestSection+LastChips.swift
// Risk → AutonomosDigestSection+LastRisk.swift

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestBody(_ digest: AtlasAutonomosDigestResponse) -> some View {
        lastDigestChips(digest)
        if let delivered = digest.last.delivered.first {
            AutonomosChrome.tag("merge \(String(delivered.mergeHash.prefix(8)))")
        }
        lastDigestRiskDecision(digest)
    }
}
