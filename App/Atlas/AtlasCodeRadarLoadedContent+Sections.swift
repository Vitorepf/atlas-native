import AtlasCore
import SwiftUI

// Radar sections stack — peel de AtlasCodeRadarLoadedContent.
// Folders/loose → AtlasCodeRadarLoadedContent+Folders.swift

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarSections: some View {
        AtlasCodeRadarStatusCapsule(model: model)
            .padding(.bottom, 18)

        if !workspace.recents.isEmpty {
            AtlasCodeRadarSectionLabel(text: "RECENTES", accessibilityID: A11yID.radarRecents)
            ForEach(workspace.recents) { repo in
                AtlasCodeRepoRow(repo: repo, issues: model.issues(for: repo.slug), trunk: model.trunk(for: repo.slug), showsFolder: true) {
                    onOpenRepo(repo.slug)
                }
                if repo.id != workspace.recents.last?.id { AtlasCodeRadarRowDivider() }
            }
        }

        radarFoldersAndLoose
    }
}
