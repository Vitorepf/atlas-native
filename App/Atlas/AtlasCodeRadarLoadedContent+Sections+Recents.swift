import AtlasCore
import SwiftUI

// Recents section — peel de AtlasCodeRadarLoadedContent+Sections.

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarRecentsSection: some View {
        if !workspace.recents.isEmpty {
            AtlasCodeRadarSectionLabel(text: "RECENTES", accessibilityID: A11yID.radarRecents)
            ForEach(workspace.recents) { repo in
                AtlasCodeRepoRow(repo: repo, issues: model.issues(for: repo.slug), trunk: model.trunk(for: repo.slug), showsFolder: true) {
                    onOpenRepo(repo.slug)
                }
                if repo.id != workspace.recents.last?.id { AtlasCodeRadarRowDivider() }
            }
        }
    }
}
