import SwiftUI
import AtlasCore

// Has-last digest — peel de AutonomosDigestSection+Predicates.

extension AutonomosNextDigestSection {
    func hasLastDigest(_ digest: AtlasAutonomosDigestResponse) -> Bool {
        digest.last.counts.delivered > 0
            || digest.last.counts.risks > 0
            || digest.last.counts.pendingDecisions > 0
            || !digest.last.delivered.isEmpty
            || !digest.last.risks.isEmpty
            || !digest.last.pendingDecisions.isEmpty
    }
}
