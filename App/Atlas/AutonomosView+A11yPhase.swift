import SwiftUI
import AtlasCore

/// Content phase ID — peel de AutonomosView+A11y.
/// Busy → AutonomosView+A11yPhase+Busy.swift

extension AutonomosView {
    var contentPhaseID: String {
        if let busy = contentPhaseBusyID { return busy }
        switch model.phase {
        case .loaded: return "loaded"
        case .failed: return "failed"
        default: return "idle"
        }
    }
}
