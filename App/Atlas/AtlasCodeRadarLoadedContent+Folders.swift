import AtlasCore
import SwiftUI

// Radar folders + loose — peel de AtlasCodeRadarLoadedContent+Sections.

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarFoldersAndLoose: some View {
        if !workspace.folders.isEmpty {
            AtlasCodeRadarSectionLabel(text: "PASTAS", accessibilityID: A11yID.radarFolders)
                .padding(.top, 22)
            ForEach(workspace.folders) { folder in
                AtlasCodeFolderRow(
                    folder: folder,
                    isExpanded: model.expandedFolders.contains(folder.slug),
                    issuesFor: { model.issues(for: $0) },
                    trunkFor: { model.trunk(for: $0) },
                    onToggle: { Task { await model.toggle(folder) } },
                    onOpenRepo: onOpenRepo
                )
                if folder.id != workspace.folders.last?.id { AtlasCodeRadarRowDivider() }
            }
        }

        if !workspace.loose.isEmpty {
            AtlasCodeRadarSectionLabel(text: "AVULSOS", accessibilityID: A11yID.radarLoose)
                .padding(.top, 22)
            ForEach(workspace.loose) { repo in
                AtlasCodeRepoRow(repo: repo, issues: model.issues(for: repo.slug), trunk: model.trunk(for: repo.slug), showsFolder: false) {
                    onOpenRepo(repo.slug)
                }
                if repo.id != workspace.loose.last?.id { AtlasCodeRadarRowDivider() }
            }
        }
    }
}
