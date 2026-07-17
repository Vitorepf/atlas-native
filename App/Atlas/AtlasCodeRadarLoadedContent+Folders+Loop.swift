import AtlasCore
import SwiftUI

// Folders loop — peel de AtlasCodeRadarLoadedContent+Folders.

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarFoldersLoop: some View {
        if !workspace.folders.isEmpty {
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
    }
}
