import SwiftUI
import AtlasCore

// Stack body — peel de ExecutionRibbon (ConversationCockpit+Ribbon).

extension ExecutionRibbon {
    var executionRibbonStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            reconnectBannerStack
            activitiesTimelineBlock
            agentLanes
            decideStrategyLine
        }
    }
}
