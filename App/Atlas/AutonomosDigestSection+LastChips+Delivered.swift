import SwiftUI
import AtlasCore

// Delivered chip — peel de AutonomosDigestSection+LastChips.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestDeliveredChip(_ count: Int) -> some View {
        if count > 0 {
            AutonomosChrome.digestChip("\(count)", "entregas")
        }
    }
}
