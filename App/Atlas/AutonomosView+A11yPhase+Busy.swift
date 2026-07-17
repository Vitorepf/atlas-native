import SwiftUI
import AtlasCore

/// Content phase ID load/fail — peel de AutonomosView+A11yPhase.

extension AutonomosView {
    var contentPhaseBusyID: String? {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        default: return nil
        }
    }
}
