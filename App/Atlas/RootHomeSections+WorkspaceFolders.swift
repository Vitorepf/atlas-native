import SwiftUI
import AtlasCore

// Workspace ForEach rows — peel de RootHomeSections+Workspaces.

extension RootHomeSections {
    @ViewBuilder
    var workspaceFolderRows: some View {
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
