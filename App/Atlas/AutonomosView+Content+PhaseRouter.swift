import SwiftUI
import AtlasCore

// Phase router — peel de AutonomosView+Content.

extension AutonomosView {
    @ViewBuilder
    var autonomosPhaseRouter: some View {
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
