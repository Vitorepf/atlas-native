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

    /// WAVE-070: face drives visibility honesty.
    var proposalFace: NightlyProposalFace { nightly.proposalFace }

    var visibilityToken: String {
        switch proposalFace {
        case .pending:
            return nightly.pendingProposal?.id ?? "pending"
        case .muted, .mutedAuto:
            return "muted"
        case .hidden:
            return "hidden"
        }
    }

    @ViewBuilder
    var nightlyContent: some View {
        if case .pending = proposalFace, let proposal = nightly.pendingProposal {
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
                .accessibilityValue(proposalFace.productWord)
                .accessibilityAddTraits(.isStaticText)
        }
    }
}
