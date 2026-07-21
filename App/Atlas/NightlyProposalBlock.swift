import SwiftUI

/// Proposta noturna — guard mute+proposta, transição editorial com Reduce Motion.
/// IDLE-COMPRESS fused host.

struct AutonomosNightlyProposalBlock: View {
    let nightly: NightlyProposalController
    let onAccept: (NightlyProposalController.ProposalPayload) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Group { nightlyContent }
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: visibilityToken)
    }

    var visibilityToken: String {
        guard let proposal = nightly.pendingProposal, !nightly.isProposalMuted else { return "hidden" }
        return proposal.id
    }

    @ViewBuilder
    var nightlyContent: some View {
        if let proposal = nightly.pendingProposal, !nightly.isProposalMuted {
            NightlyProposalCard(
                proposal: proposal,
                onAccept: { onAccept(proposal) },
                onDismiss: { nightly.dismissProposal() },
                onMute: { nightly.muteProposal(days: $0) }
            )
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
        } else if let spoken = nightly.spokenMuteStatus() {
            Color.clear
                .frame(height: 0)
                .accessibilityLabel(spoken)
                .accessibilityAddTraits(.isStaticText)
        }
    }
}
