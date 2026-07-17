import SwiftUI
import AtlasCore

/// Radar busy phase ids — peel de AtlasCodeRadarView+A11y.

extension AtlasCodeRadarView {
    var contentPhaseBusyID: String? {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .failed: return "failed"
        default: return nil
        }
    }
}
