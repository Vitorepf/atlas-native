import SwiftUI
import AtlasCore

// Decisions chip — peel de AutonomosDigestSection+LastChips.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestDecisionsChip(_ count: Int) -> some View {
        if count > 0 {
            AutonomosChrome.digestChip("\(count)", "decisões")
        }
    }
}
