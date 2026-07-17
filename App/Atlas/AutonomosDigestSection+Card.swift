import SwiftUI
import AtlasCore

// Card do digest — peel de AutonomosDigestSection.
// Schedule → AutonomosDigestSection+ScheduleCopy.swift
// Chrome → AutonomosDigestSection+CardChrome.swift
// Stack → AutonomosDigestSection+CardStack.swift
// A11y → AutonomosDigestSection+CardA11y.swift

extension AutonomosNextDigestSection {
    var digestCard: some View {
        let last = hasLastDigest(digest)
        let window = digestWindowCaption(digest)
        return digestA11yChrome(last: last, window: window,
            digestCardChrome {
                digestCardStack(last: last, window: window)
            }
        )
    }
}
