import SwiftUI
import AtlasCore

// Autonomos busy phase router — peel de AutonomosView+Content+PhaseRouter.

extension AutonomosView {
    @ViewBuilder
    var autonomosBusyPhaseRouter: some View {
        switch model.phase {
        case .idle, .loading:
            loadingContent
        case .failed(let message):
            failedContent(message: message)
        default:
            EmptyView()
        }
    }
}
