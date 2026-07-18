import SwiftUI
import AtlasCore

// Prelude shell — peel de AutonomosView+ContentShell.

extension AutonomosView {
    @ViewBuilder
    var preludeShell: some View {
        AutonomosPreludeBlocks(nightly: nightly) { nightlyStartProposal = $0 }
    }
}
