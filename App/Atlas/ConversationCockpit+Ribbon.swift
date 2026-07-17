import SwiftUI
import AtlasCore

// A RIBBON DE EXECUÇÃO — o diferencial vs Cursor. Mostra AO VIVO: quanto tempo,
// a ORQUESTRA (cada agente/provider/modelo + status), o estágio do Atlas Decide,
// e um botão Stop. Cursor mostra 1 agente; o Atlas mostra a máquina inteira.
// Lanes → ConversationCockpit+RibbonLanes.swift
// Decide → ConversationCockpit+RibbonDecide.swift
struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ReconnectBanner(bubble: bubble, reduceMotion: reduceMotion)
            SilenceWatchdog(bubble: bubble, reduceMotion: reduceMotion)
            if !bubble.activities.isEmpty {
                LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
            }
            agentLanes
            decideStrategyLine
        }
        .padding(.vertical, 10).padding(.horizontal, 14)
        .atlasCard(cornerRadius: 12, fillOpacity: 0.5)
    }
}
