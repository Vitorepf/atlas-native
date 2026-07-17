import SwiftUI
import AtlasCore

// Nightly block — peel de AutonomosLoadedSection+StackHead.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackHeadNightly: some View {
        AutonomosNightlyProposalBlock(nightly: nightly) { nightlyStartProposal = $0 }
    }
}
