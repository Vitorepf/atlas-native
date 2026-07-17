import SwiftUI
import AtlasCore

// Next digest — peel de AutonomosLoadedSection+StackDigest.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackNextDigest: some View {
        if let digest = model.digest {
            AutonomosNextDigestSection(digest: digest)
        }
    }
}
