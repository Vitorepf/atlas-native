import SwiftUI

// Visibility token — peel de NightlyProposalBlock.

extension AutonomosNightlyProposalBlock {
    var visibilityToken: String {
        guard let proposal = nightly.pendingProposal, !nightly.isProposalMuted else { return "hidden" }
        return proposal.id
    }
}
