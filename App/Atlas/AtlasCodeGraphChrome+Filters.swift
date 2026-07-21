import SwiftUI
import AtlasCore

// Worktrees — peel de AtlasCodeGraphChrome.
// Section → AtlasCodeGraphChrome+Filters+Section.swift

extension AtlasCodeView {
    func worktreesSection(_ worktrees: [AtlasCodeWorktree]) -> some View {
        worktreesSectionBody(worktrees)
    }
}
