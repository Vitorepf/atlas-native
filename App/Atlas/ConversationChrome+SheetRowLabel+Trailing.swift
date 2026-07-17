import SwiftUI

// Sheet row trailing check — peel de ConversationChrome+SheetRowLabel.

extension SheetRow {
    @ViewBuilder
    var sheetRowTrailing: some View {
        if selected {
            Image(systemName: "checkmark").font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }
}
