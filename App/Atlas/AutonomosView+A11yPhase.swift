import SwiftUI
import AtlasCore

/// Content phase ID — peel de AutonomosView+A11y.

extension AutonomosView {
    var contentPhaseID: String {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .loaded: return "loaded"
        case .failed: return "failed"
        }
    }
}
