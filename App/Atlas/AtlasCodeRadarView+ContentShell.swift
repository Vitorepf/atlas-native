import AtlasCore
import SwiftUI

// Content shell — peel de AtlasCodeRadarView.

extension AtlasCodeRadarView {
    var radarContentShell: some View {
        // Fundo como .background: a barra nativa precisa enxergar o scroll
        // para ligar o scroll-edge material (ZStack escondia).
        radarNavShell(
            radarContent
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
                .padding(.bottom, 88)
        )
        .background(AtlasTheme.bg.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            askPillDock
        }
        .sheet(isPresented: $showingAsk) {
            askConversationSheet
        }
    }
}
