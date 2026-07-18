import SwiftUI
import AtlasCore

// Index chart — peel de ArenaIndexSection+Content.

extension ArenaIndexSection {
    @ViewBuilder
    var indexContentChart: some View {
        // Medição suspeita (braço colapsado, multiplicador ≤ 0.25) = série é
        // ruído de harness, não sinal — gráfico esconde; a nota vermelha do
        // índice já diz o porquê. Gráfico que parece quebrado É quebrado.
        if let engine = chartEngine,
           (engine.atlasMultiplier ?? 1) > 0.25 {
            ArenaCompositeChart(engine: engine, reduceMotion: reduceMotion)
                .frame(height: 170)
                .padding(.top, 4)
        }
    }
}
