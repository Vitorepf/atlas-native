import SwiftUI
import AtlasCore

// Presentation-only chrome shared by RootView / WorkspaceView / SearchView.
// Route + navigation stay in RootView.
// Rows: RootChrome+Rows.swift · Controls: RootChrome+Controls.swift

/// Label de seção da home (CONVERSAS / OPERAÇÃO / WORKSPACES).
@ViewBuilder
func sectionLabel(_ t: String, accessibilityID: String? = nil) -> some View {
    Text(t)
        .font(.system(.caption, weight: .semibold))
        .tracking(1.4)
        .foregroundStyle(AtlasTheme.textTertiary)
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 6)
        .padding(.bottom, 12)
        .accessibilityAddTraits(.isHeader)
        .modifier(HomeSectionA11yID(accessibilityID))
}

private struct HomeSectionA11yID: ViewModifier {
    let id: String?
    func body(content: Content) -> some View {
        if let id {
            content.accessibilityIdentifier(id)
        } else {
            content
        }
    }
}
