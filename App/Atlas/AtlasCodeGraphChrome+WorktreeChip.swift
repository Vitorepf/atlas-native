import SwiftUI
import AtlasCore

// Worktree chip + meta (WAVE-001 W3 fuse).

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
        // Uma frase, não fragmentos: o hash (mono, 8 chars) seria soletrado
        // letra a letra pelo VoiceOver — fica só no visual, fora da fala.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(worktreeSpokenLabel(worktree))
    }

    private func worktreeSpokenLabel(_ worktree: AtlasCodeWorktree) -> String {
        var parts = [worktree.pathLabel]
        if let branch = worktree.branch?.nonEmpty { parts.append("branch \(branch)") }
        if let state = worktree.state?.nonEmpty { parts.append(state) }
        return parts.joined(separator: ", ")
    }
}
