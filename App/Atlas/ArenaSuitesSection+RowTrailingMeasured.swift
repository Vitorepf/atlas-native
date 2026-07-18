import SwiftUI
import AtlasCore

// Measured label trailing — peel de ArenaSuitesSection+RowTrailing.

extension ArenaSuiteRow {
    @ViewBuilder
    var suiteTrailingMeasuredLabel: some View {
        // Medido é o normal — silêncio. Só a exceção fala.
        if !suite.isMeasured {
            Text("não medido")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
