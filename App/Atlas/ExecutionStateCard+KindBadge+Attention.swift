import SwiftUI
import AtlasCore

// Attention kind badges — peel de ExecutionStateCard+KindBadge.

extension ExecutionStateCard {
    var kindBadgeAttention: String? {
        switch state.kind {
        case .attentionRequired: return "PAUSADO"
        case .awaitingExternal: return "AGUARDANDO"
        case .recovering: return "RECONECTANDO"
        case .replanning: return "REPLANEJANDO"
        default: return nil
        }
    }
}
