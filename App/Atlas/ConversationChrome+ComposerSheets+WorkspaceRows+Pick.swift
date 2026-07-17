import SwiftUI
import UIKit
import AtlasCore

// Workspace pick — peel de ConversationChrome+ComposerSheets+WorkspaceRows.

extension WorkspaceSheet {
    func workspaceRowPick(_ ws: Workspace) {
        onPick(ws)
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
    }
}
