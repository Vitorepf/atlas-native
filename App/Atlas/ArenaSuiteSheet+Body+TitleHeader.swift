import SwiftUI
import AtlasCore

// Suite title header — peel de ArenaSuiteSheet+Body.

extension ArenaSuiteSheet {
    var suiteBodyTitle: some View {
        Text(suite.suite.uppercased())
            .font(AtlasFont.mono(18))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(ArenaSuiteSheetA11y.spokenSuiteTitle(suite.suite))
    }
}
