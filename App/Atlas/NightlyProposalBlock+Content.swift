import SwiftUI

// Content group — peel de NightlyProposalBlock.

extension AutonomosNightlyProposalBlock {
    @ViewBuilder
    var nightlyContent: some View {
        if let proposal = nightly.pendingProposal, !nightly.isProposalMuted {
            nightlyVisibleCard(proposal)
        } else {
            nightlyMuteSpoken
        }
    }
}
