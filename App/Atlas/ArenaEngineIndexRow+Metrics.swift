import SwiftUI
import Charts
import AtlasCore

// Metrics row — peel de ArenaEngineIndexRow.

extension ArenaEngineIndexRow {
    var metricsRow: some View {
        HStack(spacing: 10) {
            metric("c/Atlas", ArenaFormat.score(engine.withAtlasComposite), color: metricColor(engine.withAtlasComposite))
            metric("sem", ArenaFormat.score(engine.withoutAtlasComposite), color: metricColor(engine.withoutAtlasComposite, fallback: AtlasTheme.textSecondary))
            if let multiplier = engine.atlasMultiplier {
                // Cor é estado: Atlas multiplicando = accent; regredindo = alert.
                metric("N×M", ArenaFormat.multiplier(multiplier), color: multiplier >= 1 ? AtlasTheme.accent : AtlasTheme.alert)
            }
        }
    }

    /// Braço com Atlas colapsado (multiplicador ≤ 0.25): quase sempre harness
    /// quebrado, nunca medição legítima — dito, nunca deadpan.
    @ViewBuilder
    var suspectMeasurementNote: some View {
        if let multiplier = engine.atlasMultiplier, multiplier <= 0.25 {
            Text("medição suspeita — verifique o braço com Atlas")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.alert)
                .accessibilityHidden(true)
        }
    }
}
