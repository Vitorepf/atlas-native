import SwiftUI
import AtlasCore

// Terminal status words — peel de ConversationCockpit+AgentStatusWord.

extension AgentRow {
    var statusWordTerminal: String {
        switch turnStatus {
        case .succeeded: return "pronto"
        case .failed: return "falhou"
        case .cancelled: return "cancelado"
        case .unknown(let raw): return raw
        default: return statusWordActive ?? "—"
        }
    }
}
