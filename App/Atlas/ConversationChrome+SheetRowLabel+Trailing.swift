import SwiftUI

// Sheet row trailing check — peel de ConversationChrome+SheetRowLabel.

extension SheetRow {
    @ViewBuilder
    var sheetRowTrailing: some View {
        if selected {
            Image(systemName: "checkmark").atlasSans(15, .semibold)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }
}
