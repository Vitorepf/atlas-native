import AtlasCore
import SwiftUI

// Linha de pasta do radar — peel de AtlasCodeRadarRows.

struct AtlasCodeFolderRow: View {
    let folder: AtlasCodeFolder
    let isExpanded: Bool
    let issuesFor: (String) -> [AtlasCodeIssue]?
    let trunkFor: (String) -> String?
    let onToggle: () -> Void
    let onOpenRepo: (String) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Só violações de repos já varridos — nil = ainda não medido, nunca conta.
    private var verifiedExceptionCount: Int {
        folder.repos.reduce(0) { total, repo in
            guard let issues = issuesFor(repo.slug), !issues.isEmpty else { return total }
            return total + issues.reduce(0) { $0 + $1.count }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onToggle()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "folder")
                        .font(.system(size: 15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .frame(width: 20)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(folder.name)
                            .font(AtlasFont.serif(16, .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(folder.repositories == 1 ? "1 repositório" : "\(folder.repositories) repositórios")
                            .font(.system(size: 11.5))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .accessibilityHidden(true)
                    Spacer(minLength: 6)
                    if verifiedExceptionCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 9, weight: .semibold))
                            Text("\(verifiedExceptionCount)")
                                .font(.system(size: 11, weight: .semibold))
                                .monospacedDigit()
                        }
                        .foregroundStyle(AtlasCodePalette.alert)
                        .accessibilityHidden(true)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .accessibilityHidden(true)
                }
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                AtlasCodeFolderRowA11y.spokenFolder(
                    name: folder.name,
                    repositoryCount: folder.repositories,
                    verifiedExceptionCount: verifiedExceptionCount,
                    isExpanded: isExpanded
                )
            )
            .accessibilityHint(AtlasCodeFolderRowA11y.spokenHint(isExpanded: isExpanded))
            .accessibilityIdentifier(A11yID.radarFolder(folder.slug))

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(folder.repos) { repo in
                        AtlasCodeRepoRow(repo: repo, issues: issuesFor(repo.slug), trunk: trunkFor(repo.slug), showsFolder: false) {
                            onOpenRepo(repo.slug)
                        }
                        .padding(.leading, 32)
                        if repo.id != folder.repos.last?.id {
                            Rectangle()
                                .fill(AtlasTheme.separator.opacity(0.4))
                                .frame(height: 0.5)
                                .padding(.leading, 32)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .padding(.bottom, 6)
                .transition(reduceMotion ? .identity : .opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: isExpanded)
    }
}
