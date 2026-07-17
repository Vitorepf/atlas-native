import SwiftUI
import AtlasCore

// Worktree chip meta — peel de AtlasCodeGraphChrome+WorktreeChip.

extension AtlasCodeView {
    func worktreeChipMeta(_ worktree: AtlasCodeWorktree) -> some View {
        HStack(spacing: 5) {
            if let branch = worktree.branch?.nonEmpty {
                Text(branch)
            }
            if let head = worktree.head?.nonEmpty {
                Text(String(head.prefix(8)))
                    .monospacedDigit()
            }
            if let state = worktree.state?.nonEmpty {
                Text(state)
            }
        }
        .font(AtlasFont.mono(9))
        .foregroundStyle(AtlasTheme.textTertiary)
    }
}
