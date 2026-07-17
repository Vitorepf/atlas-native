import SwiftUI
import AtlasCore

// Predicados do digest — peel de AutonomosDigestSection+Last.

extension AutonomosNextDigestSection {
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
