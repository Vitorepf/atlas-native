import SwiftUI
import AtlasCore

// Timing color — peel de LiveNowRow+Timing.

extension LiveNowRow {
    var timingColor: Color {
        switch session.timing {
        case .running: return AtlasTheme.accent
        case .paused: return AtlasTheme.textTertiary
        case .finished: return AtlasTheme.textSecondary
        }
    }
}
