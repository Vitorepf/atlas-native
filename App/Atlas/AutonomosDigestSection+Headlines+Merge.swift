import SwiftUI
import AtlasCore

// Merge tag headline — peel de AutonomosDigestSection+Headlines.

extension AutonomosNextDigestSection {
    func digestMergeTag(_ digest: AtlasAutonomosDigestResponse) -> String? {
        digest.last.delivered.first.map { String($0.mergeHash.prefix(8)) }
    }
}
