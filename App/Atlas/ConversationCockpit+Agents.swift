import SwiftUI
import AtlasCore

// Agentes — peel de ConversationCockpit (régua anti-inchaço).
// Status → ConversationCockpit+AgentStatus.swift
// Model → ConversationCockpit+AgentModel.swift
// Chrome → ConversationCockpit+AgentChrome.swift

struct AgentRow: View {
    let agent: ExecAgent
    var compactLane = false
    var body: some View {
        agentRowChrome(
            HStack(spacing: 8) {
                Circle().fill(statusColor).frame(width: 6, height: 6)
                Text(agent.agent ?? providerWord(agent.provider))
                    .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textSecondary)
                agentModelLabel
                Spacer()
                Text(statusWord).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textTertiary)
            }
        )
    }
}
