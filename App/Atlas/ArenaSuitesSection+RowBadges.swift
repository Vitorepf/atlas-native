import SwiftUI
import AtlasCore

// Suite leading badges — peel de ArenaSuitesSection+RowLeading.

extension ArenaSuiteRow {
    var suiteLeadingBadges: some View {
        HStack(spacing: 8) {
            Text(suite.suite.uppercased())
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityHidden(true)
            if !suite.adapterInstalled {
                Text("sem adapter")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            if suite.hasRegression {
                Circle().fill(AtlasTheme.alert).frame(width: 7, height: 7)
                    .accessibilityHidden(true)
            }
        }
    }
}
