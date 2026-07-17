import SwiftUI
import AtlasCore

// Predicados do digest — peel de AutonomosDigestSection+Last.
// Headlines → AutonomosDigestSection+Headlines.swift
// Window → AutonomosDigestSection+WindowCaption.swift

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
}
