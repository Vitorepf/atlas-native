import SwiftUI
import AtlasCore

// Corpo do último digest — peel de AutonomosDigestSection (régua ≤100).
// Predicates → AutonomosDigestSection+Predicates.swift
// Chips → AutonomosDigestSection+LastChips.swift

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestBody(_ digest: AtlasAutonomosDigestResponse) -> some View {
        lastDigestChips(digest)
        if let delivered = digest.last.delivered.first {
            AutonomosChrome.tag("merge \(String(delivered.mergeHash.prefix(8)))")
        }
        if let risk = digest.last.risks.first {
            Text(risk.title?.nonEmpty ?? risk.reason?.nonEmpty ?? risk.severity)
                .font(.caption)
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
        if let decision = digest.last.pendingDecisions.first {
            Text(decision.title)
                .font(.caption)
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}
