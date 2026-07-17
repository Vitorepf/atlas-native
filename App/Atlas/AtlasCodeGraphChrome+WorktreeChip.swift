import SwiftUI
import AtlasCore

// Worktree chip — peel de AtlasCodeGraphChrome+Filters.
// Meta → AtlasCodeGraphChrome+WorktreeMeta.swift

extension AtlasCodeView {
    func worktreeChip(_ worktree: AtlasCodeWorktree) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(worktree.pathLabel)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
            worktreeChipMeta(worktree)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Capsule().fill(AtlasTheme.bgRecessed))
        .overlay(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }
}
