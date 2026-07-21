import SwiftUI
import AtlasCore

// Trailing chevron — peel de LiveNowRow+Content.

extension LiveNowRow {
    @ViewBuilder
    var rowChevron: some View {
        if navigable {
            Image(systemName: "chevron.right")
                .atlasSans(12, .semibold)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
