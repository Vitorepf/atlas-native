import SwiftUI
import AtlasCore

// Trailing branch — peel de ArenaSuitesSection+RowTrailing.

extension ArenaSuiteRow {
    @ViewBuilder
    var suiteTrailing: some View {
        if suite.engines.first != nil,
           ArenaSuitesSectionA11y.hasSparkline(for: suite) {
            suiteTrailingSparkline
        } else {
            suiteTrailingMeasuredLabel
        }
    }
}
