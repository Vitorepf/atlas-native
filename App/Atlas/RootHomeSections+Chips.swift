import SwiftUI
import AtlasCore

// Chips de filtro workspace — peel de RootHomeSections+Conversation.
// Chip → RootHomeSections+Chip.swift · Row → RootHomeSections+ChipsRow.swift

extension RootHomeSections {
    @ViewBuilder
    var homeWorkspaceChips: some View {
        if showsWorkspaceChips {
            ScrollView(.horizontal, showsIndicators: false) {
                homeWorkspaceChipsRow
            }
            .accessibilityLabel(filterChipsSpokenLabel())
            .accessibilityIdentifier(A11yID.homeWorkspaceChips)
        }
    }
}
