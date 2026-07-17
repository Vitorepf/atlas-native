import SwiftUI
import AtlasCore

// Prelude shell — peel de AutonomosView+ContentShell.

extension AutonomosView {
    @ViewBuilder
    var preludeShell: some View {
        AutonomosPreludeBlocks(nightly: nightly, rhythmSampleDays: rhythmSampleDays) { nightlyStartProposal = $0 }
    }
}
