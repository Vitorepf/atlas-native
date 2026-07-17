import SwiftUI
import AtlasCore

// Engine card — peel de ArenaSuiteSheet.
// Captions → ArenaSuiteSheet+EngineCaptions.swift

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
            engineCardCaptions(engine)
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenEngine(engine))
    }
}
