import AtlasCore
import SwiftUI

// Radar folders — peel de AtlasCodeRadarLoadedContent+Sections.
// Loose → AtlasCodeRadarLoadedContent+Loose.swift

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
        radarLooseSection
    }
}
