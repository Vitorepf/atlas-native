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
