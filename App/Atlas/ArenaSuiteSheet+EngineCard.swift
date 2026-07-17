import SwiftUI
import AtlasCore

// Engine card — peel de ArenaSuiteSheet.
// Captions → ArenaSuiteSheet+EngineCaptions.swift
// Score → ArenaSuiteSheet+EngineScore.swift

extension ArenaSuiteSheet {
    func engineCard(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(engine.engine)
                    .font(.system(.headline))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Spacer()
                engineCardScore(engine)
            }
            engineCardCaptions(engine)
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenEngine(engine))
    }
}
