import SwiftUI
import AtlasCore

// Status helpers — peel de ConversationCockpit+Agents.
// Word → ConversationCockpit+AgentStatusWord.swift
// Active → ConversationCockpit+AgentStatus+Active.swift

extension AgentRow {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: agent.status) }

    var statusColor: Color {
        if let active = statusColorActive { return active }
        switch turnStatus {
        case .failed, .cancelled: return AtlasTheme.domOperacional
        default: return AtlasTheme.textTertiary
        }
    }
}
