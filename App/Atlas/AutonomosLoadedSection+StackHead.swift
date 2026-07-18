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
        // O acionável abre a tela: a única pergunta que ela responde é
        // "preciso fazer algo?". Resumos vêm depois, colapsados.
        loadedStackMidAwaiting
        loadedStackDigest
    }
}
