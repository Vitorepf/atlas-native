import SwiftUI
import AtlasCore

// Toolbar — peel de ArenaEngineSheet.

extension ArenaEngineSheet {
    var engineToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: ArenaEngineSheetA11y.closeLabel,
                spokenHint: ArenaEngineSheetA11y.closeHint,
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}
