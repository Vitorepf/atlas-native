import SwiftUI
import AtlasCore

extension RootHomeSections {
    @ViewBuilder
    var workspacesSection: some View {
        sectionLabel("WORKSPACES", accessibilityID: A11yID.homeWorkspacesSection)
        WorkspaceRow(
            icon: "tray.full",
            name: "Todas as conversas",
            count: session.threads.count > 0 ? session.threads.count : nil,
            a11yID: A11yID.homeWorkspaceAll,
            spokenOverride: workspaceSpokenLabel(
                name: "Todas as conversas",
                count: session.threads.count > 0 ? session.threads.count : nil
            ),
            spokenHint: "abre todas as conversas"
        ) {
            onNavigate(.workspace(key: nil, title: "Todas"))
        }
        workspaceFolderRows
    }
}
