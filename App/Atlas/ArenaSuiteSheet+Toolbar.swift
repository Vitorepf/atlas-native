import SwiftUI
import AtlasCore

// Toolbar suite sheet — peel de ArenaSuiteSheet.

extension ArenaSuiteSheet {
    @ToolbarContentBuilder
    var suiteToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: ArenaSuiteSheetA11y.closeLabel,
                spokenHint: ArenaSuiteSheetA11y.closeHint,
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}
