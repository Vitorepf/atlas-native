import SwiftUI
import AtlasCore

// Predicate show — peel de AutonomosDigestSection.

extension AutonomosNextDigestSection {
    @ViewBuilder
    var digestBody: some View {
        if shouldShowDigest(digest) {
            digestCard
        } else {
            AutonomosDigestEmptyState()
        }
    }
}
