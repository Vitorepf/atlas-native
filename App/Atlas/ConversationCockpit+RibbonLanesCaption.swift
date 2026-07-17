import SwiftUI
import AtlasCore

// LANES caption — peel de ConversationCockpit+RibbonLanes.

extension ExecutionRibbon {
    @ViewBuilder
    var agentLanesCaption: some View {
        if bubble.agents.count >= 2 {
            Text("LANES")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}
