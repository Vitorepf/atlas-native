import SwiftUI
import AtlasCore

// A11y shell — peel de ArenaSuiteSheet.

extension ArenaSuiteSheet {
    var suitePresentation: some View {
        NavigationStack {
            suiteScrollBody
        }
        .accessibilityIdentifier(A11yID.arenaSuiteSheet)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenSheet(suite))
        .accessibilityHint(ArenaSuiteSheetA11y.sheetHint)
    }
}
