import SwiftUI

/// Proposta noturna — guard mute+proposta, transição editorial com Reduce Motion.
/// Visible → NightlyProposalBlock+Visible.swift
/// Token → NightlyProposalBlock+Token.swift
/// Content → NightlyProposalBlock+Content.swift
struct AutonomosNightlyProposalBlock: View {
    let nightly: NightlyProposalController
    let onAccept: (NightlyProposalController.ProposalPayload) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Group { nightlyContent }
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: visibilityToken)
    }
}
