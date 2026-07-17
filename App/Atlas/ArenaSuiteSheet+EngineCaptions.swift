import SwiftUI
import AtlasCore

// Captions do engine card — peel de ArenaSuiteSheet+EngineCard.

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCardCaptions(_ engine: AtlasArenaSuiteEngine) -> some View {
        if let cases = ArenaSuiteSheetA11yCaptions.casesCaption(for: engine) {
            Text(cases)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        if let duration = ArenaSuiteSheetA11yCaptions.durationCaption(for: engine) {
            Text(duration)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        if !engine.history.isEmpty {
            SuiteSparkline(engine: engine).frame(height: 90)
                .accessibilityHidden(true)
        }
    }
}
