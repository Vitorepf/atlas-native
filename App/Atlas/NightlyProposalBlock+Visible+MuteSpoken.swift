import SwiftUI

// Mute spoken — peel de NightlyProposalBlock+Visible.

extension AutonomosNightlyProposalBlock {
    @ViewBuilder
    var nightlyMuteSpoken: some View {
        if let spoken = nightly.spokenMuteStatus() {
            Color.clear
                .frame(height: 0)
                .accessibilityLabel(spoken)
                .accessibilityAddTraits(.isStaticText)
        }
    }
}
