import SwiftUI
import AtlasCore

// Trailing da ThreadRow — peel de RootChrome+ThreadRow+Content.
// Status → RootChrome+ThreadRow+TrailingStatus.swift

extension ThreadRow {
    @ViewBuilder
    var rowTrailing: some View {
        rowTrailingStatus
        Image(systemName: "chevron.right")
            .atlasSans(13, .semibold).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}
