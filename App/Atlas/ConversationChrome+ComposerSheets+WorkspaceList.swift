import SwiftUI
import UIKit

// Lista de workspaces — peel de WorkspaceSheet.
// Header → ConversationChrome+ComposerSheets+WorkspaceHeader.swift

extension WorkspaceSheet {
    @ViewBuilder
    var workspaceList: some View {
        workspaceListHeader
        ForEach(workspaces) { ws in
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
}
