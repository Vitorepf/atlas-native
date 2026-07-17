import SwiftUI
import AtlasCore

// Trailing da ThreadRow — peel de RootChrome+ThreadRow+Content.
// Status → RootChrome+ThreadRow+TrailingStatus.swift

extension ThreadRow {
    @ViewBuilder
    var rowTrailing: some View {
        rowTrailingStatus
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold)).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}
