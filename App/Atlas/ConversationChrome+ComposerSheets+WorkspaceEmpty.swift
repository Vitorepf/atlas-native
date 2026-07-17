import SwiftUI
import UIKit

// Workspace empty — peel de ConversationChrome+ComposerSheets+Rows.

extension WorkspaceSheet {
    var workspaceEmptyLabel: some View {
        Text("Nenhum workspace nas conversas carregadas")
            .font(.system(size: 15))
            .foregroundStyle(AtlasTheme.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .accessibilityLabel(ComposerSheetA11y.workspaceEmpty)
    }
}
