import SwiftUI
import AtlasCore

// Chips row — peel de RootHomeSections+Chips.

extension RootHomeSections {
    @ViewBuilder
    var homeWorkspaceChipsRow: some View {
        HStack(spacing: 8) {
            homeFilterChip("Livres", key: nil)
            homeFilterChip("Todas", key: "__all")
            ForEach(session.workspaces) { workspace in
                homeFilterChip(workspace.name, key: workspace.id)
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 10)
    }
}
