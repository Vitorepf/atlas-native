import SwiftUI
import UIKit

struct WorkspaceSheet: View {
    let workspaces: [Workspace]
    let current: String?
    let onPick: (Workspace) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        SheetShell(title: "Workspace") {
            if workspaces.isEmpty {
                Text("Nenhum workspace nas conversas carregadas")
                    .font(.system(size: 15))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .accessibilityLabel(ComposerSheetA11y.workspaceEmpty)
            } else {
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
        }
        .accessibilityIdentifier(A11yID.workspaceSheet)
        .accessibilityLabel("workspace da conversa")
        .accessibilityHint(ComposerSheetA11y.workspaceSheetHint)
    }

    func workspaceCountLine(_ count: Int) -> String {
        count == 1 ? "1 conversa carregada" : "\(count) conversas carregadas"
    }
}
