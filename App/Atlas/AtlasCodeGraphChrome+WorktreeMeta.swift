import SwiftUI
import AtlasCore

// Worktree chip meta — peel de AtlasCodeGraphChrome+WorktreeChip.
// BranchHead → AtlasCodeGraphChrome+WorktreeMeta+BranchHead.swift

extension AtlasCodeView {
    func worktreeChipMeta(_ worktree: AtlasCodeWorktree) -> some View {
        HStack(spacing: 5) {
            worktreeBranchHead(worktree)
            if let state = worktree.state?.nonEmpty {
                Text(state)
            }
        }
        .font(AtlasFont.mono(9))
        .foregroundStyle(AtlasTheme.textTertiary)
    }
}
