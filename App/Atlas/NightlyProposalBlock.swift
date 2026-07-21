import SwiftUI

/// Proposta noturna — guard mute+proposta, transição editorial com Reduce Motion.
struct AutonomosNightlyProposalBlock: View {
    let nightly: NightlyProposalController
    let onAccept: (NightlyProposalController.ProposalPayload) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private var visibilityToken: String {
        guard let proposal = nightly.pendingProposal, !nightly.isProposalMuted else { return "hidden" }
        return proposal.id
    }

    var body: some View {
        Group {
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
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: visibilityToken)
    }
}
