import SwiftUI
import AtlasCore

// Sparkline — peel de ArenaSuiteSheet+EngineCaptions.

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineHistorySparkline(_ engine: AtlasArenaSuiteEngine) -> some View {
        if !engine.history.isEmpty {
            SuiteSparkline(engine: engine).frame(height: 90)
                .accessibilityHidden(true)
        }
    }
}
