import SwiftUI
import AtlasCore

// Cabeça do stack Autônomos (nightly→digest) — peel de AutonomosLoadedSection+Stack.
// Digest → AutonomosLoadedSection+StackDigest.swift

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackHead: some View {
        loadedStackHeadNightly
        loadedStackHeadRhythm
        loadedStackHeadFleetSummary
        loadedStackDigest
    }
}
