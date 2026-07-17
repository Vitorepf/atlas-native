import SwiftUI

// Card visível da proposta noturna — peel de NightlyProposalBlock.

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
