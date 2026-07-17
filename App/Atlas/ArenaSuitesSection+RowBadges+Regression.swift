import SwiftUI
import AtlasCore

// Regression indicator — peel de ArenaSuitesSection+RowBadges.

extension ArenaSuiteRow {
    @ViewBuilder
    var suiteRegressionBadge: some View {
        if suite.hasRegression {
            Circle().fill(AtlasTheme.alert).frame(width: 7, height: 7)
                .accessibilityHidden(true)
        }
    }
}
