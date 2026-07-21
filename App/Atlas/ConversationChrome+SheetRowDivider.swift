import SwiftUI

// Divider overlay — peel de ConversationChrome+SheetRow.

extension SheetRow {
    var sheetRowDivider: some View {
        Divider().overlay(AtlasTheme.separator).padding(.leading, 24)
    }
}
