import SwiftUI
import AtlasCore

// Score trailing do engine card — peel de ArenaSuiteSheet+EngineCard.

extension ArenaSuiteSheet {
    func engineCardScore(_ engine: AtlasArenaSuiteEngine) -> some View {
        Text(ArenaFormat.score(engine.score))
            .font(AtlasFont.mono(16))
            .foregroundStyle(engine.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}
