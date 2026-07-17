import SwiftUI
import AtlasCore

// Attention spoken kinds — peel de ExecutionStateCard+Presentation.

extension ExecutionStateCard {
    var spokenKindAttention: String? {
        switch state.kind {
        case .attentionRequired: return "execução pausada, aguardando decisão"
        case .awaitingExternal: return "aguardando sistema externo"
        case .recovering: return "reconectando"
        case .replanning: return "replanejando"
        default: return nil
        }
    }
}
