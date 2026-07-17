import SwiftUI
import AtlasCore

// Should-show digest — peel de AutonomosDigestSection+Predicates.

extension AutonomosNextDigestSection {
    func shouldShowDigest(_ digest: AtlasAutonomosDigestResponse) -> Bool {
        digest.nextDigestAt?.nonEmpty != nil
            || hasLastDigest(digest)
            || digest.schedule.reason?.nonEmpty != nil
    }
}
