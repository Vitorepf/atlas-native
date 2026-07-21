import SwiftUI
import AtlasCore

// Attention kind badges — peel de ExecutionStateCard+KindBadge.
// Wait → ExecutionStateCard+KindBadge+Attention+Wait.swift

extension ExecutionStateCard {
    var kindBadgeAttention: String? {
        if let wait = kindBadgeWait { return wait }
        switch state.kind {
        case .recovering: return "RECONECTANDO"
        case .replanning: return "REPLANEJANDO"
        default: return nil
        }
    }
}
