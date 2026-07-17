import SwiftUI
import AtlasCore

// Measured label trailing — peel de ArenaSuitesSection+RowTrailing.

extension ArenaSuiteRow {
    @ViewBuilder
    var suiteTrailingMeasuredLabel: some View {
        if suite.isMeasured {
            Text("medido")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        } else {
            Text("não medido")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
