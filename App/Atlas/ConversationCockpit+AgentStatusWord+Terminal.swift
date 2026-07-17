import SwiftUI
import AtlasCore

// Terminal status words — peel de ConversationCockpit+AgentStatusWord.
// Done → ConversationCockpit+AgentStatusWord+Terminal+Done.swift

extension AgentRow {
    var statusWordTerminal: String {
        if let done = statusWordDone { return done }
        if case .unknown(let raw) = turnStatus { return raw }
        return statusWordActive ?? "—"
    }
}
