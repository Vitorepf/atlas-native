import AtlasCore
import SwiftUI

// Radar loose repos — peel de AtlasCodeRadarLoadedContent+Folders.

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarLooseSection: some View {
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
