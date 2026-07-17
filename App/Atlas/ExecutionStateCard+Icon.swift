import SwiftUI
import AtlasCore

// Execution icon — peel de ExecutionStateCard+PresentationChrome.

extension ExecutionStateCard {
    var icon: String {
        switch state.kind {
        case .attentionRequired: return "exclamationmark.shield"
        case .awaitingExternal: return "hourglass"
        case .recovering: return "arrow.triangle.2.circlepath"
        case .replanning: return "arrow.triangle.branch"
        case .failed: return "xmark.octagon"
        case .completed: return "checkmark.seal"
        }
    }

    static func clock(_ ms: Int) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}
