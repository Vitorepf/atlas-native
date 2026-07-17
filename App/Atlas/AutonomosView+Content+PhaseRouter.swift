import SwiftUI
import AtlasCore

// Phase router — peel de AutonomosView+Content.
// Busy → AutonomosView+Content+PhaseRouter+Busy.swift

extension AutonomosView {
    @ViewBuilder
    var autonomosPhaseRouter: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            autonomosBusyPhaseRouter
        case .loaded:
            loadedContent
        }
    }
}
