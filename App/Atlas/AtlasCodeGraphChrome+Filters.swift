import SwiftUI
import AtlasCore

// Worktrees — peel de AtlasCodeGraphChrome.
// Chips → +Chips · Chip → +WorktreeChip.swift
// Header → AtlasCodeGraphChrome+Filters+Header.swift
// Scroll → AtlasCodeGraphChrome+Filters+Scroll.swift

extension AtlasCodeView {
    func worktreesSection(_ worktrees: [AtlasCodeWorktree]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            worktreesSectionHeader
            worktreesSectionScroll(worktrees)
        }
    }
}
