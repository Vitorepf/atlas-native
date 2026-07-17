import SwiftUI
import Charts
import AtlasCore

// Header SUITES — peel de ArenaSuitesSection.

extension ArenaSuitesSection {
    var suitesHeader: some View {
        HStack {
            Text("SUITES")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Text("\(suites.count)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
    }
}
