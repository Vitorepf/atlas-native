import SwiftUI
import AtlasCore

// WAVE-156 density peel — graph worktrees chrome

extension AtlasCodeView {
    // MARK: Worktrees (WAVE-087 Judgment)

    @ViewBuilder
    func worktreesSection(_ worktrees: [AtlasCodeWorktree]) -> some View {
        let face = AtlasCodeWorktreeJudgment.sectionFace(worktrees)
        if face != .silence {
            VStack(alignment: .leading, spacing: 8) {
                Text("WORKTREES")
                    .font(AtlasFont.mono(10))
                    .tracking(1.1)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier(A11yID.codeGraphWorktrees)
                    .accessibilityLabel(AtlasCodeWorktreeJudgment.spokenSection(worktrees))
                    .accessibilityValue(face.productWord)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(AtlasCodeWorktreeJudgment.rank(worktrees)) { worktree in
                            worktreeChip(worktree)
                        }
                    }
                }
            }
        }
    }

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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AtlasCodeWorktreeJudgment.spokenChip(worktree))
    }
}
