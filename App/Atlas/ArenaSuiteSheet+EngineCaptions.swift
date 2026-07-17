import SwiftUI
import AtlasCore

// Captions do engine card — peel de ArenaSuiteSheet+EngineCard.
// Cases → ArenaSuiteSheet+EngineCaptions+Cases.swift
// Duration → ArenaSuiteSheet+EngineCaptions+Duration.swift
// Sparkline → ArenaSuiteSheet+EngineCaptions+Sparkline.swift

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCardCaptions(_ engine: AtlasArenaSuiteEngine) -> some View {
        engineCasesCaption(engine)
        engineDurationCaption(engine)
        engineHistorySparkline(engine)
    }
}
