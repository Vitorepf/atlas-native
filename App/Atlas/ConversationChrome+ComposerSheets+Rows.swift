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
                workspaceList
            }
        }
        .accessibilityIdentifier(A11yID.workspaceSheet)
        .accessibilityLabel("workspace da conversa")
        .accessibilityHint(ComposerSheetA11y.workspaceSheetHint)
    }
}
