import SwiftUI
import AtlasCore

/// Arena failed phase id — peel de AtlasArenaView+A11y.

extension AtlasArenaView {
    var contentPhaseFailedID: String {
        model.isDomainUnavailable ? "domain-unavailable" : "failed"
    }
}
