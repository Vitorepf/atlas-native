import SwiftUI

/// Proposta noturna — guard mute+proposta, transição editorial com Reduce Motion.
/// Visible → NightlyProposalBlock+Visible.swift
struct AutonomosNightlyProposalBlock: View {
    let nightly: NightlyProposalController
    let onAccept: (NightlyProposalController.ProposalPayload) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var visibilityToken: String {
        guard let proposal = nightly.pendingProposal, !nightly.isProposalMuted else { return "hidden" }
        return proposal.id
    }

    var body: some View {
        Group {
            if let proposal = nightly.pendingProposal, !nightly.isProposalMuted {
                nightlyVisibleCard(proposal)
            } else {
                nightlyMuteSpoken
            }
        }
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: visibilityToken)
    }
}
