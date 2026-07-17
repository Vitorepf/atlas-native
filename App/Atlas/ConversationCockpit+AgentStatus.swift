import SwiftUI
import AtlasCore

// Status helpers — peel de ConversationCockpit+Agents.
// Word → ConversationCockpit+AgentStatusWord.swift

extension AgentRow {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: agent.status) }

    var statusColor: Color {
        switch turnStatus {
        case .processing: return AtlasTheme.accent
        case .succeeded: return AtlasTheme.domAutonomos
        case .failed, .cancelled: return AtlasTheme.domOperacional
        default: return AtlasTheme.textTertiary
        }
    }
}
