import SwiftUI
import AtlasCore

// Suite title header — peel de ArenaSuiteSheet+Body.

extension ArenaSuiteSheet {
    var suiteBodyTitle: some View {
        Text(ArenaDisplay.suite(suite.suite))
            .font(AtlasFont.serif(22, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(ArenaSuiteSheetA11y.spokenSuiteTitle(suite.suite))
    }
}
