import SwiftUI
import AtlasCore

// Terminal icons — peel de ExecutionStateCard+Icon.

extension ExecutionStateCard {
    var iconTerminal: String {
        switch state.kind {
        case .failed: return "xmark.octagon"
        case .completed: return "checkmark.seal"
        default: return iconAttention ?? "exclamationmark.shield"
        }
    }
}
