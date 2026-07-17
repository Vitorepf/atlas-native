import SwiftUI
import UIKit

// Lista de workspaces — peel de WorkspaceSheet.
// Header → ConversationChrome+ComposerSheets+WorkspaceHeader.swift
// Rows → ConversationChrome+ComposerSheets+WorkspaceRows.swift

extension WorkspaceSheet {
    @ViewBuilder
    var workspaceList: some View {
        workspaceListHeader
        ForEach(workspaces) { ws in
            workspaceRow(ws)
        }
    }
}
