import SwiftUI
import Charts
import AtlasCore

// Metrics row — peel de ArenaEngineIndexRow.

extension ArenaEngineIndexRow {
    var metricsRow: some View {
        HStack(spacing: 10) {
            metric("c/Atlas", ArenaFormat.score(engine.withAtlasComposite), color: metricColor(engine.withAtlasComposite))
            metric("sem", ArenaFormat.score(engine.withoutAtlasComposite), color: metricColor(engine.withoutAtlasComposite, fallback: AtlasTheme.textSecondary))
            if engine.atlasMultiplier != nil {
                metric("N×M", ArenaFormat.multiplier(engine.atlasMultiplier), color: AtlasTheme.textPrimary)
            }
        }
    }
}
