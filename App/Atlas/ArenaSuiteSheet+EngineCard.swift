import SwiftUI
import AtlasCore

// Engine card — peel de ArenaSuiteSheet.

extension ArenaSuiteSheet {
    func engineCard(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(engine.engine)
                    .font(.system(.headline))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Spacer()
                Text(ArenaFormat.score(engine.score))
                    .font(AtlasFont.mono(16))
                    .foregroundStyle(engine.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
            }
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
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenEngine(engine))
    }
}
