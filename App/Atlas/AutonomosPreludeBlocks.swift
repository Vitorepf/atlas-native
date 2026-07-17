import SwiftUI
import AtlasCore

/// Proposta noturna + linha de ritmo — compartilhado entre idle/loading/failed.
struct AutonomosPreludeBlocks: View {
    let nightly: NightlyProposalController
    let rhythmSampleDays: Int?
    let onAcceptProposal: (NightlyProposalController.ProposalPayload) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        AutonomosNightlyProposalBlock(nightly: nightly, onAccept: onAcceptProposal)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
            .animation(
                reduceMotion ? nil : AtlasMotion.editorial,
                value: nightly.pendingProposal?.id
            )
        AutonomosRhythmLearningLine(sampleDays: rhythmSampleDays)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
    }
}
