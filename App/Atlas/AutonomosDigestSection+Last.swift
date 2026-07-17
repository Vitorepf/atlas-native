import SwiftUI
import AtlasCore

// Corpo do último digest + predicados — peel de AutonomosDigestSection (régua ≤100).

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

    func shouldShowDigest(_ digest: AtlasAutonomosDigestResponse) -> Bool {
        digest.nextDigestAt?.nonEmpty != nil
            || hasLastDigest(digest)
            || digest.schedule.reason?.nonEmpty != nil
    }

    func hasLastDigest(_ digest: AtlasAutonomosDigestResponse) -> Bool {
        digest.last.counts.delivered > 0
            || digest.last.counts.risks > 0
            || digest.last.counts.pendingDecisions > 0
            || !digest.last.delivered.isEmpty
            || !digest.last.risks.isEmpty
            || !digest.last.pendingDecisions.isEmpty
    }

    /// Janela governada publicada pelo servidor — sem inventar horário de agenda.
    func digestWindowCaption(_ digest: AtlasAutonomosDigestResponse) -> String? {
        let window = digest.last.window
        guard window.hours > 0 else { return nil }
        var parts = ["janela \(window.hours)h"]
        if let ended = AtlasTime.date(window.endedAt) {
            parts.append("fechou há \(atlasRelativeAgePT(since: ended))")
        }
        return parts.joined(separator: " · ")
    }

    func digestMergeTag(_ digest: AtlasAutonomosDigestResponse) -> String? {
        digest.last.delivered.first.map { String($0.mergeHash.prefix(8)) }
    }

    func digestRiskHeadline(_ digest: AtlasAutonomosDigestResponse) -> String? {
        digest.last.risks.first.flatMap { $0.title?.nonEmpty ?? $0.reason?.nonEmpty ?? $0.severity }
    }

    func digestDecisionHeadline(_ digest: AtlasAutonomosDigestResponse) -> String? {
        digest.last.pendingDecisions.first?.title
    }
}
