import SwiftUI
import AtlasCore

// Cabeça do stack Autônomos (nightly→digest) — peel de AutonomosLoadedSection+Stack.
// Digest → AutonomosLoadedSection+StackDigest.swift

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackHead: some View {
        AutonomosNightlyProposalBlock(nightly: nightly) { nightlyStartProposal = $0 }
        AutonomosRhythmLearningLine(sampleDays: rhythmSampleDays)
        if let fleet = model.fleet {
            AutonomosFleetSummary(
                fleet: fleet,
                incidentPresent: model.taskHealth?.incidents.present == true
            )
        }
        loadedStackDigest
    }
}
