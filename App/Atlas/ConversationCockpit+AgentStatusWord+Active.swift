import SwiftUI
import AtlasCore

// Active/queued status words — peel de ConversationCockpit+AgentStatusWord.
// Queued → ConversationCockpit+AgentStatusWord+Active+Queued.swift

extension AgentRow {
    var statusWordActive: String? {
        if let queued = statusWordQueued { return queued }
        switch turnStatus {
        case .awaitingUserChoice: return "aguardando"
        case .awaitingExternal: return "aguardando externo"
        default: return nil
        }
    }
}
