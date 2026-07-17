import SwiftUI
import AtlasCore

// A RIBBON DE EXECUÇÃO — o diferencial vs Cursor. Mostra AO VIVO: quanto tempo,
// a ORQUESTRA (cada agente/provider/modelo + status), o estágio do Atlas Decide,
// e um botão Stop. Cursor mostra 1 agente; o Atlas mostra a máquina inteira.
// Lanes → ConversationCockpit+RibbonLanes.swift
// Decide → ConversationCockpit+RibbonDecide.swift
// Banners → ExecutionRibbon+BannerStack.swift · Timeline → +ActivitiesBlock.swift
// Chrome → ExecutionRibbon+CardChrome.swift
struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var body: some View {
        executionRibbonCard(
            VStack(alignment: .leading, spacing: 8) {
                reconnectBannerStack
                activitiesTimelineBlock
                agentLanes
                decideStrategyLine
            }
        )
    }
}
