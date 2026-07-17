import SwiftUI
import UIKit
import AtlasCore

// Workspace row loop — peel de ConversationChrome+ComposerSheets+WorkspaceList.

extension WorkspaceSheet {
    @ViewBuilder
    func workspaceRow(_ ws: Workspace) -> some View {
        let isSelected = ws.name == current
        SheetRow(
            label: ws.name,
            sub: workspaceCountLine(ws.count),
            selected: isSelected,
            accessibilityLabel: ComposerSheetA11y.workspaceLabel(
                name: ws.name, count: ws.count, selected: isSelected
            ),
            accessibilityIdentifier: A11yID.workspaceRow(ws.id)
        ) {
            onPick(ws)
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
        }
    }
}
