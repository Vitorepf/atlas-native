import SwiftUI
import Charts
import AtlasCore

// Scores row do motor — peel de ArenaEngineSheet+Summary.

extension ArenaEngineSheet {
    var engineScoreRow: some View {
        HStack(spacing: 10) {
            Text("c/Atlas \(ArenaFormat.score(engine.withAtlasComposite))")
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Text("sem \(ArenaFormat.score(engine.withoutAtlasComposite))")
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            Text(ArenaFormat.multiplier(engine.atlasMultiplier))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
        }
        .font(AtlasFont.mono(11))
    }
}
