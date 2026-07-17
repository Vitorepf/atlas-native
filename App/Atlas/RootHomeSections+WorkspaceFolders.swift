import SwiftUI
import AtlasCore

// Workspace ForEach rows — peel de RootHomeSections+Workspaces.
// Row → RootHomeSections+WorkspaceFolderRow.swift

extension RootHomeSections {
    @ViewBuilder
    var workspaceFolderRows: some View {
        ForEach(session.workspaces) { ws in
            rowDivider
            workspaceFolderRow(ws)
        }
    }
}
