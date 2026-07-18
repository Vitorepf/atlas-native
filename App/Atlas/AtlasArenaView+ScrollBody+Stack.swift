import SwiftUI
import AtlasCore

// Scroll stack — peel de AtlasArenaView+ScrollBody.

extension AtlasArenaView {
    var arenaScrollStack: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            // Banner vermelho de regressão REMOVIDO (veto do operador
            // 2026-07-18: alarme no topo era o anti-premium). Regressão segue
            // dita onde é assunto: home (sublinha da Arena) e disclosure das
            // suítes ("N em regressão").
            content
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, 18)
    }
}
