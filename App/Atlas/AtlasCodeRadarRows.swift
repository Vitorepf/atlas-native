import AtlasCore
import SwiftUI

// Linhas de repositório e pasta do radar — peel de AtlasCodeRadarSections.

// MARK: - Linha de repositório

struct AtlasCodeRepoRow: View {
    let repo: AtlasCodeRepoRef
    let issues: [AtlasCodeIssue]?
    /// A trunk real deste repo: a frase da issue fala o nome da linha.
    var trunk: String? = nil
    /// Nos recentes a pasta situa; dentro da pasta seria redundante.
    let showsFolder: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 7) {
                        Text(repo.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        if showsFolder, let folder = repo.folder {
                            Text(folder)
                                .font(.system(size: 10))
                                .foregroundStyle(AtlasTheme.textTertiary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1.5)
                                .background(Capsule().fill(AtlasTheme.surface))
                        }
                    }
                    // A história do repo em português — só quando existe.
                    if let issues, let first = issues.first {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(first.isSevere ? AtlasCodePalette.alert : AtlasCodePalette.alert.opacity(0.45))
                                .frame(width: 4.5, height: 4.5)
                            Text(issues.count == 1 ? first.headline(trunk: trunk) : "\(first.headline(trunk: trunk)) · +\(issues.count - 1)")
                                .font(.system(size: 12))
                                .foregroundStyle(AtlasTheme.textSecondary)
                                .lineLimit(1)
                        }
                    }
                }
                Spacer(minLength: 6)
                if let age = AtlasCodeAge.short(from: repo.lastCommitAt) {
                    Text(age)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            }
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilityIdentifier(A11yID.radarRepo(repo.slug))
    }

    private var accessibilityText: String {
        var parts = [repo.name]
        if let issues, !issues.isEmpty { parts.append(issues.map { $0.headline(trunk: trunk) }.joined(separator: ", ")) }
        if let age = AtlasCodeAge.short(from: repo.lastCommitAt) { parts.append("último commit \(age)") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Linha de pasta (produto)

struct AtlasCodeFolderRow: View {
    let folder: AtlasCodeFolder
    let isExpanded: Bool
    let issuesFor: (String) -> [AtlasCodeIssue]?
    let trunkFor: (String) -> String?
    let onToggle: () -> Void
    let onOpenRepo: (String) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var exceptionCount: Int {
        folder.repos.reduce(0) { $0 + (issuesFor($1.slug)?.reduce(0) { $0 + $1.count } ?? 0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    Image(systemName: "folder")
                        .font(.system(size: 15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .frame(width: 20)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(folder.name)
                            .font(AtlasFont.serif(16, .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(folder.repositories == 1 ? "1 repositório" : "\(folder.repositories) repositórios")
                            .font(.system(size: 11.5))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    Spacer(minLength: 6)
                    if exceptionCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 9, weight: .semibold))
                            Text("\(exceptionCount)")
                                .font(.system(size: 11, weight: .semibold))
                                .monospacedDigit()
                        }
                        .foregroundStyle(AtlasCodePalette.alert)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(folder.name), \(folder.repositories) repositórios\(exceptionCount > 0 ? ", \(exceptionCount) problemas" : "")")
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
                        }
                    }
                }
                .padding(.bottom, 6)
                .transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: isExpanded)
    }
}
