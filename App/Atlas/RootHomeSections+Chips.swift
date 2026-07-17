import SwiftUI
import AtlasCore

// Chips de filtro workspace — peel de RootHomeSections+Conversation.
// Chip → RootHomeSections+Chip.swift

extension RootHomeSections {
    @ViewBuilder
    var homeWorkspaceChips: some View {
        if showsWorkspaceChips {
            ScrollView(.horizontal, showsIndicators: false) {
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
            .accessibilityLabel(filterChipsSpokenLabel())
            .accessibilityIdentifier(A11yID.homeWorkspaceChips)
        }
    }
}
