import SwiftUI
import AtlasCore

// Agentes — peel de ConversationCockpit (régua anti-inchaço).
// Status → ConversationCockpit+AgentStatus.swift
// Model → ConversationCockpit+AgentModel.swift
// Chrome → ConversationCockpit+AgentChrome.swift
// Content → ConversationCockpit+Agents+Content.swift

struct AgentRow: View {
    let agent: ExecAgent
    var compactLane = false
    var body: some View {
        agentRowChrome(agentRowContent)
    }
}
