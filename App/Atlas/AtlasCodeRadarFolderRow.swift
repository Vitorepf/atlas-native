import AtlasCore
import SwiftUI

/// Linha de pasta do radar — expand/collapse + repos + spoken honesty.
struct AtlasCodeFolderRow: View {
    let folder: AtlasCodeFolder
    let isExpanded: Bool
    let issuesFor: (String) -> [AtlasCodeIssue]?
    let trunkFor: (String) -> String?
    let onToggle: () -> Void
    let onOpenRepo: (String) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// Só violações de repos já varridos — nil = ainda não medido, nunca conta limpo.
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
                    HStack(spacing: 12) {
                        Image(systemName: "folder")
                            .atlasSans(15)
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .frame(width: 20)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(folder.name)
                                .atlasSans(15, .semibold)
                                .foregroundStyle(AtlasTheme.textPrimary)
                            Text(folder.repositories == 1
                                 ? "1 repositório"
                                 : "\(folder.repositories) repositórios")
                                .atlasSans(11.5)
                                .foregroundStyle(AtlasTheme.textTertiary)
                        }
                        .accessibilityHidden(true)
                    }
                    Spacer(minLength: 6)
                    if verifiedExceptionCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                                .atlasSans(9, .semibold)
                            Text("\(verifiedExceptionCount)")
                                .atlasSans(11, .semibold)
                                .monospacedDigit()
                        }
                        .foregroundStyle(AtlasCodePalette.alert)
                        .accessibilityHidden(true)
                    }
                    Image(systemName: "chevron.right")
                        .atlasSans(12, .semibold)
                        .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .accessibilityHidden(true)
                }
                .padding(.vertical, 14)
                .frame(minHeight: 48, alignment: .center)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenFolderLabel)
            .accessibilityHint(isExpanded ? "recolhe a pasta" : "expande a pasta")
            .accessibilityAddTraits(isExpanded ? [.isButton, .isSelected] : .isButton)
            .accessibilityIdentifier(A11yID.radarFolder(folder.slug))

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(folder.repos) { repo in
                        AtlasCodeRepoRow(
                            repo: repo,
                            issues: issuesFor(repo.slug),
                            trunk: trunkFor(repo.slug),
                            showsFolder: false
                        ) {
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

    private var spokenFolderLabel: String {
        var parts = [
            folder.name,
            folder.repositories == 1 ? "1 repositório" : "\(folder.repositories) repositórios"
        ]
        if verifiedExceptionCount > 0 {
            let n = verifiedExceptionCount
            parts.append("\(n) sem retorno\(n == 1 ? "" : "s") verificado\(n == 1 ? "" : "s")")
        }
        if isExpanded { parts.append("expandida") }
        return parts.joined(separator: ", ")
    }
}
