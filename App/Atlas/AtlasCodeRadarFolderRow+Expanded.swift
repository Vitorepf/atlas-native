import SwiftUI
import AtlasCore

/// Repos expandidos — peel de AtlasCodeFolderRow (régua ≤100).
/// Separator → AtlasCodeRadarFolderRow+Separator.swift

extension AtlasCodeFolderRow {
    @ViewBuilder var expandedRepos: some View {
        if isExpanded {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(folder.repos) { repo in
                    AtlasCodeRepoRow(repo: repo, issues: issuesFor(repo.slug), trunk: trunkFor(repo.slug), showsFolder: false) {
                        onOpenRepo(repo.slug)
                    }
                    .padding(.leading, 32)
                    expandedRepoSeparator(after: repo)
                }
            }
            .padding(.bottom, 6)
            .transition(reduceMotion ? .identity : .opacity)
        }
    }
}
