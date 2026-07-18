import SwiftUI
import AtlasCore

/// Proposta noturna + linha de ritmo — compartilhado entre idle/loading/failed.
struct AutonomosPreludeBlocks: View {
    let nightly: NightlyProposalController
    let onAcceptProposal: (NightlyProposalController.ProposalPayload) -> Void

    var body: some View {
        AutonomosNightlyProposalBlock(nightly: nightly, onAccept: onAcceptProposal)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
        AutonomosRhythmLearningLine()
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
    }
}
