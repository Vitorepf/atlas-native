import SwiftUI
import AtlasCore

// Chips row — peel de RootHomeSections+Chips.

extension RootHomeSections {
    @ViewBuilder
    var homeWorkspaceChipsRow: some View {
        // ScrollView só destrava o overflow: com Dynamic Type grande os chips
        // passam da borda e ficavam inalcançáveis; na régua padrão nada muda.
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                homeFilterChip("Livres", key: nil)
                homeFilterChip("Todas", key: "__all")
                ForEach(session.workspaces) { workspace in
                    homeFilterChip(workspace.name, key: workspace.id)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
        }
        .padding(.bottom, 10)
    }
}
