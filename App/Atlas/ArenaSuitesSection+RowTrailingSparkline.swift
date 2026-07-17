import SwiftUI
import Charts
import AtlasCore

// Sparkline trailing — peel de ArenaSuitesSection+RowTrailing.

extension ArenaSuiteRow {
    @ViewBuilder
    var suiteTrailingSparkline: some View {
        if let engine = suite.engines.first,
           ArenaSuitesSectionA11y.hasSparkline(for: suite) {
            SuiteSparkline(engine: engine).frame(width: 64, height: 30)
        }
    }
}
