import SwiftUI
import AtlasCore

extension RootHomeSections {
    @ViewBuilder
    var workspacesSection: some View {
        sectionLabel("WORKSPACES", accessibilityID: A11yID.homeWorkspacesSection)
        WorkspaceRow(
            icon: "tray.full",
            name: "Todas as conversas",
            count: session.threads.count > 0 ? session.threads.count : nil
        ) {
            onNavigate(.workspace(key: nil, title: "Todas"))
        }
        .accessibilityLabel(workspaceSpokenLabel(
            name: "Todas as conversas",
            count: session.threads.count > 0 ? session.threads.count : nil
        ))
        .accessibilityHint("abre todas as conversas")
        .accessibilityIdentifier(A11yID.homeWorkspaceAll)
        ForEach(session.workspaces) { ws in
            rowDivider
            WorkspaceRow(
                icon: "folder",
                name: ws.name,
                count: ws.count > 0 ? ws.count : nil
            ) {
                onNavigate(.workspace(key: ws.id, title: ws.name))
            }
            .accessibilityLabel(workspaceSpokenLabel(
                name: ws.name,
                count: ws.count > 0 ? ws.count : nil
            ))
            .accessibilityHint("abre conversas deste workspace")
            .accessibilityIdentifier(A11yID.homeWorkspace(ws.id))
        }
    }
}
