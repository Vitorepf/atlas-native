import SwiftUI
import AtlasCore

// Toolbar close — peel de ArenaRunSheet.

extension ArenaRunSheet {
    @ToolbarContentBuilder
    var runToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: spokenCloseLabel(),
                spokenHint: spokenCloseHint(),
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}
