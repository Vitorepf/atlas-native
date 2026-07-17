import SwiftUI
import AtlasCore

// Chips do último digest — peel de AutonomosDigestSection+Last.
// HStack → AutonomosDigestSection+LastChips+HStack.swift

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestChips(_ digest: AtlasAutonomosDigestResponse) -> some View {
        lastDigestChipsMotion(
            lastDigestChipsRow(digest.last.counts),
            counts: digest.last.counts
        )
    }
}
