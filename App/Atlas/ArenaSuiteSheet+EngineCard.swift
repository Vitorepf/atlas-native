import SwiftUI
import AtlasCore

// Engine card — peel de ArenaSuiteSheet.
// Captions → ArenaSuiteSheet+EngineCaptions.swift
// Score → ArenaSuiteSheet+EngineScore.swift
// Header → ArenaSuiteSheet+EngineCard+Header.swift

extension ArenaSuiteSheet {
    func engineCard(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            engineCardHeader(engine)
            engineCardCaptions(engine)
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenEngine(engine))
    }
}
