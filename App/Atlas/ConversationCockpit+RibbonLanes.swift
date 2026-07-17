import SwiftUI
import AtlasCore

// Agent lanes — peel de ConversationCockpit+Ribbon.
// Caption → ConversationCockpit+RibbonLanesCaption.swift

extension ExecutionRibbon {
    @ViewBuilder
    var agentLanes: some View {
        if !bubble.agents.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                agentLanesCaption
                ForEach(bubble.agents) { AgentRow(agent: $0, compactLane: bubble.agents.count >= 2) }
            }.padding(.leading, 24)
        }
    }
}
