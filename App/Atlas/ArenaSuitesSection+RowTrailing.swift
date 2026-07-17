import SwiftUI
import AtlasCore

// Trailing measured/sparkline — peel de ArenaSuiteRow.

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

    var subtitle: String {
        suite.arenaSubtitleText
    }
}
