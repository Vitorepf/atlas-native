import SwiftUI

// Card visível — peel de NightlyProposalBlock+Visible.

extension AutonomosNightlyProposalBlock {
    @ViewBuilder
    func nightlyVisibleCard(_ proposal: NightlyProposalController.ProposalPayload) -> some View {
        NightlyProposalCard(
            proposal: proposal,
            onAccept: { onAccept(proposal) },
            onDismiss: { nightly.dismissProposal() },
            onMute: { nightly.muteProposal(days: $0) }
        )
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
    }
}
