import SwiftUI
import AtlasCore

// Worktree chip — peel de AtlasCodeGraphChrome+Filters.

extension AtlasCodeView {
    func worktreeChip(_ worktree: AtlasCodeWorktree) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(worktree.pathLabel)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
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
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Capsule().fill(AtlasTheme.bgRecessed))
        .overlay(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }
}
