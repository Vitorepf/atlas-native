import SwiftUI
import AtlasCore

// Repo rows list — peel de AtlasCodeRadarFolderRow+Expanded.

extension AtlasCodeFolderRow {
    var expandedReposList: some View {
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
