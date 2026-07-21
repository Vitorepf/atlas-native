import SwiftUI
import AtlasCore

// WAVE-022 — Execution ribbon consumes ConversationExecutionPhase faces.

struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void

    private var face: ConversationExecutionFace {
        ConversationExecutionPhase.face(for: bubble)
    }

    var body: some View {
        executionRibbonStack
            .padding(.vertical, 10).padding(.horizontal, 14)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ConversationExecutionPhase.spokenFace(face))
    }

    var executionRibbonStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            reconnectBannerStack
            if face != .finished && face != .quiet {
                activitiesTimelineBlock
                agentLanes
                decideStrategyLine
            }
        }
    }

    @ViewBuilder
    var reconnectBannerStack: some View {
        // WAVE-012 + WAVE-022: dual-surface primary is strip; ribbon silence when streaming.
        if ConversationExecutionPhase.ribbonShowsReconnectBanner(bubble) {
            ReconnectBanner(bubble: bubble, reduceMotion: reduceMotion)
        }
        if ConversationExecutionPhase.ribbonShowsSilenceWatchdog(bubble) {
            SilenceWatchdog(bubble: bubble, reduceMotion: reduceMotion)
        }
    }

    @ViewBuilder
    var activitiesTimelineBlock: some View {
        if !bubble.activities.isEmpty {
            LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
        }
    }

    @ViewBuilder
    var agentLanes: some View {
        // WAVE-049: attention-ranked lanes (failed/awaiting first).
        let ranked = ConversationAgentLanesJudgment.rank(bubble.agents)
        let lanesFace = ConversationAgentLanesJudgment.face(from: bubble.agents)
        if !ranked.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                if let kicker = lanesFace.kicker {
                    Text(kicker)
                        .font(AtlasFont.mono(10))
                        .tracking(1.1)
                        .foregroundStyle(
                            lanesFace.productWord == "attention"
                                ? AtlasTheme.domOperacional
                                : AtlasTheme.textTertiary
                        )
                        .accessibilityLabel(lanesFace.spokenFace)
                        .accessibilityIdentifier(A11yID.executionAgentLanes)
                }
                ForEach(ranked) { AgentRow(agent: $0, compactLane: ranked.count >= 2) }
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
