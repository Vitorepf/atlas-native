import SwiftUI
import AtlasCore

// Worktrees scroll — peel de AtlasCodeGraphChrome+Filters.

extension AtlasCodeView {
    func worktreesSectionScroll(_ worktrees: [AtlasCodeWorktree]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(worktrees) { worktree in
                    worktreeChip(worktree)
                }
            }
        }
    }
}
