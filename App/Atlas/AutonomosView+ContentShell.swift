import SwiftUI
import AtlasCore

// Idle/loading/failed shells — peel de AutonomosView+Content.
// Failed → AutonomosView+ContentFailed.swift

extension AutonomosView {
    @ViewBuilder
    var preludeShell: some View {
        AutonomosPreludeBlocks(nightly: nightly, rhythmSampleDays: rhythmSampleDays) { nightlyStartProposal = $0 }
    }

    var loadingContent: some View {
        Group {
            preludeShell
            Spacer()
            TraceEvidenceLoading(text: "consultando a frota…", reduceMotion: reduceMotion)
            Spacer()
        }
    }
}
