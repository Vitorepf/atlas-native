import SwiftUI
import UIKit

// Lista de workspaces — peel de WorkspaceSheet.

extension WorkspaceSheet {
    @ViewBuilder
    var workspaceList: some View {
        Text("pastas das conversas carregadas · vale no próximo envio")
            .font(.system(size: 12))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityAddTraits(.isHeader)
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

    func workspaceCountLine(_ count: Int) -> String {
        count == 1 ? "1 conversa carregada" : "\(count) conversas carregadas"
    }
}
