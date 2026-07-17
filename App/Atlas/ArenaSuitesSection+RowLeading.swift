import SwiftUI
import AtlasCore

// Leading labels — peel de ArenaSuiteRow.
// Badges → ArenaSuitesSection+RowBadges.swift

extension ArenaSuiteRow {
    var suiteLeading: some View {
        VStack(alignment: .leading, spacing: 4) {
            suiteLeadingBadges
            Text(subtitle)
                .font(.system(.caption))
                .foregroundStyle(suite.isMeasured ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
