import SwiftUI
import AtlasCore

// Wait icons — peel de ExecutionStateCard+Icon+Attention.

extension ExecutionStateCard {
    var iconWait: String? {
        switch state.kind {
        case .attentionRequired: return "exclamationmark.shield"
        case .awaitingExternal: return "hourglass"
        default: return nil
        }
    }
}
