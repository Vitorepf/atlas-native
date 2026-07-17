import SwiftUI

/// Proposta noturna — guard mute+proposta, transição editorial com Reduce Motion.
/// Visible → NightlyProposalBlock+Visible.swift
/// Token → NightlyProposalBlock+Token.swift
struct AutonomosNightlyProposalBlock: View {
    let nightly: NightlyProposalController
    let onAccept: (NightlyProposalController.ProposalPayload) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

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
