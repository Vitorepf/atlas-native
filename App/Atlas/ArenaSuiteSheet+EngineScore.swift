import SwiftUI
import AtlasCore

// Score trailing do engine card — peel de ArenaSuiteSheet+EngineCard.

extension ArenaSuiteSheet {
    func engineCardScore(_ engine: AtlasArenaSuiteEngine) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text(ArenaFormat.score(engine.score))
                .font(AtlasFont.serif(38))
            if engine.score != nil {
                Text("/10")
                    .font(AtlasFont.mono(9, .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
            .foregroundStyle(engine.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}
