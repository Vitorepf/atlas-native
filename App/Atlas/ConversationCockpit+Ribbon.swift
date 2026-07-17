import SwiftUI
import AtlasCore

// A RIBBON DE EXECUÇÃO — o diferencial vs Cursor. Mostra AO VIVO: quanto tempo,
// a ORQUESTRA (cada agente/provider/modelo + status), o estágio do Atlas Decide,
// e um botão Stop. Cursor mostra 1 agente; o Atlas mostra a máquina inteira.
struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let notice = bubble.reconnectNotice {
                ExecutionBanner(
                    text: notice,
                    icon: "wifi.exclamationmark",
                    tint: AtlasTheme.accent,
                    accessibilityIdentifier: A11yID.executionReconnectBanner
                )
            }
            SilenceWatchdog(bubble: bubble)
            if !bubble.activities.isEmpty {
                LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
            }
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
            if let strat = bubble.decideStrategy {
                Text("atlas decide · \(strat)" + (bubble.decideStage.map { " → \($0)" } ?? ""))
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).padding(.leading, 24)
            }
        }
        .padding(.vertical, 10).padding(.horizontal, 14)
        .atlasCard(cornerRadius: 12, fillOpacity: 0.5)
    }
}
