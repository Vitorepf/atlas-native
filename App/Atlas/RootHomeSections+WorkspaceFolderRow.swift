import SwiftUI
import AtlasCore

// Single workspace row — peel de RootHomeSections+WorkspaceFolders.

extension RootHomeSections {
    func workspaceFolderRow(_ ws: Workspace) -> some View {
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
