import SwiftUI
import AtlasCore

// Worktrees section — peel de AtlasCodeGraphChrome+Filters.

extension AtlasCodeView {
    func worktreesSectionBody(_ worktrees: [AtlasCodeWorktree]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            worktreesSectionHeader
            worktreesSectionScroll(worktrees)
        }
    }
}
