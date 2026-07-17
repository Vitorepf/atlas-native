import SwiftUI
import AtlasCore

// Attention/wait icons — peel de ExecutionStateCard+Icon.

extension ExecutionStateCard {
    var iconAttention: String? {
        switch state.kind {
        case .attentionRequired: return "exclamationmark.shield"
        case .awaitingExternal: return "hourglass"
        case .recovering: return "arrow.triangle.2.circlepath"
        case .replanning: return "arrow.triangle.branch"
        default: return nil
        }
    }
}
