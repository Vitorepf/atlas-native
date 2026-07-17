import SwiftUI
import AtlasCore

// Worktrees — peel de AtlasCodeGraphChrome.
// Chips → AtlasCodeGraphChrome+Chips.swift

extension AtlasCodeView {
    func worktreesSection(_ worktrees: [AtlasCodeWorktree]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WORKTREES")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier(A11yID.codeGraphWorktrees)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(worktrees) { worktree in
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
            }
        }
    }
}
