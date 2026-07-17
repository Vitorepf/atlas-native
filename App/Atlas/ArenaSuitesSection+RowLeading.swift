import SwiftUI
import AtlasCore

// Leading labels — peel de ArenaSuiteRow.

extension ArenaSuiteRow {
    var suiteLeading: some View {
        VStack(alignment: .leading, spacing: 4) {
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
            Text(subtitle)
                .font(.system(.caption))
                .foregroundStyle(suite.isMeasured ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
