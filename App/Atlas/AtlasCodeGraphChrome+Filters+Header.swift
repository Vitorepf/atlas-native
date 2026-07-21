import SwiftUI
import AtlasCore

// Worktrees header — peel de AtlasCodeGraphChrome+Filters.

extension AtlasCodeView {
    var worktreesSectionHeader: some View {
        Text("WORKTREES")
            .font(AtlasFont.mono(10))
            .tracking(1.1)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(A11yID.codeGraphWorktrees)
    }
}
