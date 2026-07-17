import SwiftUI
import AtlasCore

// Agent lanes — peel de ConversationCockpit+Ribbon.

extension ExecutionRibbon {
    @ViewBuilder
    var agentLanes: some View {
        if !bubble.agents.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                if bubble.agents.count >= 2 {
                    Text("LANES")
                        .font(AtlasFont.mono(10))
                        .tracking(1.1)
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                ForEach(bubble.agents) { AgentRow(agent: $0, compactLane: bubble.agents.count >= 2) }
            }.padding(.leading, 24)
        }
    }
}
