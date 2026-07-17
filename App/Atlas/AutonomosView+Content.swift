import SwiftUI
import AtlasCore

// Conteúdo por fase — peel de AutonomosView (régua ≤100).
// Shell → AutonomosView+ContentShell.swift
// Loaded → AutonomosView+ContentLoaded.swift

extension AutonomosView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle, .loading:
            loadingContent
        case .failed(let message):
            failedContent(message: message)
        case .loaded:
            loadedContent
        }
    }
}
