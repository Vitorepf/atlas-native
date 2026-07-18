import SwiftUI
import AtlasCore

// Suite title badges — peel de ArenaSuitesSection+RowBadges.

extension ArenaSuiteRow {
    @ViewBuilder
    var suiteTitleBadges: some View {
        Text(ArenaDisplay.suite(suite.suite))
            .font(.system(.subheadline, weight: .medium))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(1)
            .accessibilityHidden(true)
        if !suite.adapterInstalled {
            Text("sem adapter")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
