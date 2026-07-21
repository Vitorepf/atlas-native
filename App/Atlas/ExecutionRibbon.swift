import SwiftUI
import AtlasCore

// Execution ribbon — IDLE-COMPRESS (peels + cockpit host co-located).

struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void

    var body: some View {
        executionRibbonStack
            .padding(.vertical, 10).padding(.horizontal, 14)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
    }

    var executionRibbonStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            reconnectBannerStack
            activitiesTimelineBlock
            agentLanes
            decideStrategyLine
        }
    }

    @ViewBuilder
    var reconnectBannerStack: some View {
        // WAVE-012 dual-surface: strip owns primary reconnect while streaming.
        if !(bubble.streaming && bubble.showsReconnectSurface) {
            ReconnectBanner(bubble: bubble, reduceMotion: reduceMotion)
        }
        SilenceWatchdog(bubble: bubble, reduceMotion: reduceMotion)
    }

    @ViewBuilder
    var activitiesTimelineBlock: some View {
        if !bubble.activities.isEmpty {
            LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
        }
    }

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

    @ViewBuilder
    var decideStrategyLine: some View {
        if let strat = bubble.decideStrategy {
            Text("atlas decide · \(strat)" + (bubble.decideStage.map { " → \($0)" } ?? ""))
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).padding(.leading, 24)
        }
    }
}
