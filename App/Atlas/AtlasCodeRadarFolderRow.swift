import AtlasCore
import SwiftUI

// Linha de pasta do radar — peel de AtlasCodeRadarRows.
// Header → +Header · Expandidos → +Expanded · spoken → FolderRow+A11y.
struct AtlasCodeFolderRow: View {
    let folder: AtlasCodeFolder
    let isExpanded: Bool
    let issuesFor: (String) -> [AtlasCodeIssue]?
    let trunkFor: (String) -> String?
    let onToggle: () -> Void
    let onOpenRepo: (String) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// Só violações de repos já varridos — nil = ainda não medido, nunca conta.
    var verifiedExceptionCount: Int {
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
                folderHeaderLabel
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
            expandedRepos
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: isExpanded)
    }
}
