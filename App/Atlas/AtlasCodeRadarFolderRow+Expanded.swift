import SwiftUI
import AtlasCore

/// Repos expandidos — peel de AtlasCodeFolderRow (régua ≤100).

extension AtlasCodeFolderRow {
    @ViewBuilder var expandedRepos: some View {
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
}
