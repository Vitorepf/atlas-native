import SwiftUI
import AtlasCore

// Sheet a11y — peel de ArenaRunSheet.

extension ArenaRunSheet {
    func runSheetA11y<V: View>(_ content: V) -> some View {
        content
            .onAppear { seedDefaultsIfNeeded() }
            .accessibilityIdentifier(A11yID.arenaRunSheet)
            .accessibilityLabel(spokenSheetLabel())
            .accessibilityHint(spokenSheetHint())
    }
}
