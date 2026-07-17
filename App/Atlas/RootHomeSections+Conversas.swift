import SwiftUI
import AtlasCore

// Seção CONVERSAS — peel de RootHomeSections+Loaded.

extension RootHomeSections {
    @ViewBuilder
    var conversasSection: some View {
        sectionLabel("CONVERSAS", accessibilityID: A11yID.homeConversasSection)
        homeWorkspaceChips
        WorkspaceRow(icon: "bubble.left.and.bubble.right", name: homeConversationLabel,
                     count: homeConversationCount,
                     detail: session.auditModeEnabled ? auditDetail : nil) {
            onNavigate(homeConversationRoute)
        }
        .accessibilityLabel(conversasEntrySpokenLabel())
        .accessibilityHint("abre conversas deste filtro")
        .accessibilityIdentifier(A11yID.homeConversasEntry)
    }
}
