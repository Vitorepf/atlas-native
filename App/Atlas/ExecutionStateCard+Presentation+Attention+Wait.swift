import SwiftUI
import AtlasCore

// Wait spoken kinds — peel de ExecutionStateCard+Presentation+Attention.

extension ExecutionStateCard {
    var spokenKindWait: String? {
        switch state.kind {
        case .attentionRequired: return "execução pausada, aguardando decisão"
        case .awaitingExternal: return "aguardando sistema externo"
        default: return nil
        }
    }
}
