import SwiftUI
import AtlasCore

// KindBadge wait — peel de ExecutionStateCard+KindBadge+Attention.

extension ExecutionStateCard {
    var kindBadgeWait: String? {
        switch state.kind {
        case .attentionRequired: return "PAUSADO"
        case .awaitingExternal: return "AGUARDANDO"
        default: return nil
        }
    }
}
