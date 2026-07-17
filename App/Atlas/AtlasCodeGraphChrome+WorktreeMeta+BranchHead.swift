import SwiftUI
import AtlasCore

// branch/head — peel de AtlasCodeGraphChrome+WorktreeMeta.

extension AtlasCodeView {
    @ViewBuilder
    func worktreeBranchHead(_ worktree: AtlasCodeWorktree) -> some View {
        if let branch = worktree.branch?.nonEmpty {
            Text(branch)
        }
        if let head = worktree.head?.nonEmpty {
            Text(String(head.prefix(8)))
                .monospacedDigit()
        }
    }
}
