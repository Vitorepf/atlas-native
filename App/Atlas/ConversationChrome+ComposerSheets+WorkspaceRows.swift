import SwiftUI
import UIKit
import AtlasCore

// Workspace row loop — peel de ConversationChrome+ComposerSheets+WorkspaceList.
// RowBuild → ConversationChrome+ComposerSheets+WorkspaceRows+RowBuild.swift

extension WorkspaceSheet {
    @ViewBuilder
    func workspaceRow(_ ws: Workspace) -> some View {
        workspaceRowBuild(ws, isSelected: ws.name == current)
    }
}
