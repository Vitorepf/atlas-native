import SwiftUI
import AtlasCore

// Status word — peel de ConversationCockpit+AgentStatus.

extension AgentRow {
    var statusWord: String {
        switch turnStatus {
        case .queued: return "na fila"
        case .processing: return "processando"
        case .succeeded: return "pronto"
        case .failed: return "falhou"
        case .cancelled: return "cancelado"
        case .awaitingUserChoice: return "aguardando"
        case .awaitingExternal: return "aguardando externo"
        case .unknown(let raw): return raw
        }
    }
}
