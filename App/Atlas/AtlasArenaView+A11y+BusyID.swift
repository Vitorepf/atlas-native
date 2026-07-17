import SwiftUI
import AtlasCore

/// Arena busy phase ids — peel de AtlasArenaView+A11y.

extension AtlasArenaView {
    var contentPhaseBusyID: String? {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .loaded: return "loaded"
        default: return nil
        }
    }
}
