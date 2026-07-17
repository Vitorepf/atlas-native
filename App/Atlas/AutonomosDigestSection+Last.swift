import SwiftUI
import AtlasCore

// Corpo do último digest — peel de AutonomosDigestSection (régua ≤100).
// Predicates → AutonomosDigestSection+Predicates.swift

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestBody(_ digest: AtlasAutonomosDigestResponse) -> some View {
        HStack(spacing: 8) {
            if digest.last.counts.delivered > 0 {
                AutonomosChrome.digestChip("\(digest.last.counts.delivered)", "entregas")
            }
            if digest.last.counts.risks > 0 {
                AutonomosChrome.digestChip("\(digest.last.counts.risks)", "riscos")
            }
            if digest.last.counts.pendingDecisions > 0 {
                AutonomosChrome.digestChip("\(digest.last.counts.pendingDecisions)", "decisões")
            }
        }
        .animation(reduceMotion ? nil : .default, value: digest.last.counts.delivered)
        .animation(reduceMotion ? nil : .default, value: digest.last.counts.risks)
        .animation(reduceMotion ? nil : .default, value: digest.last.counts.pendingDecisions)
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
