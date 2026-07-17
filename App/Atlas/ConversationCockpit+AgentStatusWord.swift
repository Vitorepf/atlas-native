import SwiftUI
import AtlasCore

// Status word — peel de ConversationCockpit+AgentStatus.
// Active → ConversationCockpit+AgentStatusWord+Active.swift
// Terminal → ConversationCockpit+AgentStatusWord+Terminal.swift

extension AgentRow {
    var statusWord: String {
        statusWordActive ?? statusWordTerminal
    }
}
