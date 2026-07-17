import SwiftUI
import AtlasCore

// Active/queued status words — peel de ConversationCockpit+AgentStatusWord.

extension AgentRow {
    var statusWordActive: String? {
        switch turnStatus {
        case .queued: return "na fila"
        case .processing: return "processando"
        case .awaitingUserChoice: return "aguardando"
        case .awaitingExternal: return "aguardando externo"
        default: return nil
        }
    }
}
