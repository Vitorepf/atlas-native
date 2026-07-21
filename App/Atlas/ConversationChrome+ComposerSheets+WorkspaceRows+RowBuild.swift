import SwiftUI
import UIKit
import AtlasCore

// Workspace row build — peel de ConversationChrome+ComposerSheets+WorkspaceRows.

extension WorkspaceSheet {
    @ViewBuilder
    func workspaceRowBuild(_ ws: Workspace, isSelected: Bool) -> some View {
        SheetRow(
            label: ws.name,
            sub: workspaceCountLine(ws.count),
            selected: isSelected,
            accessibilityLabel: ComposerSheetA11y.workspaceLabel(
                name: ws.name, count: ws.count, selected: isSelected
            ),
            accessibilityIdentifier: A11yID.workspaceRow(ws.id)
        ) {
            workspaceRowPick(ws)
        }
    }
}
