import SwiftUI
import AtlasCore

// Linhas da timeline de commits — peel de AtlasCodeWhySheet (régua ~120).

extension AtlasCodeWhySheet {
    func whyRow(_ commit: AtlasCodeWhy.Commit, index: Int, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(AtlasTheme.accent)
                    .frame(width: 7, height: 7)
                    .accessibilityHidden(true)
                if !isLast {
                    Rectangle()
                        .fill(AtlasTheme.accent.opacity(0.35))
                        .frame(width: 1)
                        .frame(minHeight: 56)
                        .accessibilityHidden(true)
                }
            }
            .padding(.top, 7)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                if let quote = commit.provenance?.quote {
                    Text("\u{201C}\(quote)\u{201D}")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityHidden(true)
                } else {
                    Text("sem proveniência registrada")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
                Text(meta(for: commit))
                    .font(AtlasFont.mono(10.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text(commit.subject)
                    .font(.system(size: 11))
                    .foregroundStyle(AtlasTheme.textSecondary.opacity(0.75))
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            .padding(.bottom, isLast ? 0 : 18)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenCommit(commit))
        .accessibilityIdentifier(A11yID.whyRow(index))
    }

    func meta(for commit: AtlasCodeWhy.Commit) -> String {
        var parts = [commit.agentLabel]
        if let when = commit.when {
            parts.append("há \(AtlasCodeRelativeTime.short(from: Int(when.timeIntervalSince1970)))")
        }
        parts.append(commit.shortHash)
        if let obra = commit.provenance?.obra, !obra.isEmpty { parts.append(obra) }
        return parts.joined(separator: " · ")
    }
}
