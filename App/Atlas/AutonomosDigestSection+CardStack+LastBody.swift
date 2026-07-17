import SwiftUI
import AtlasCore

// Last body branch — peel de AutonomosDigestSection+CardStack.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func digestCardLastBody(last: Bool) -> some View {
        if last {
            lastDigestBody(digest)
        }
    }
}
