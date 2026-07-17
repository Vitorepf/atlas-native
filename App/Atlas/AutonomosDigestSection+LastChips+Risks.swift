import SwiftUI
import AtlasCore

// Risks chip — peel de AutonomosDigestSection+LastChips.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestRisksChip(_ count: Int) -> some View {
        if count > 0 {
            AutonomosChrome.digestChip("\(count)", "riscos")
        }
    }
}
