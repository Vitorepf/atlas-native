import AtlasCore
import SwiftUI

/// Conteúdo carregado do radar — peel de `AtlasCodeRadarSections`.
struct AtlasCodeRadarLoadedContent: View {
    let workspace: AtlasCodeWorkspaceResponse
    let model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
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
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }
}
