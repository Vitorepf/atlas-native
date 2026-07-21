import SwiftUI

// Sheet row leading — peel de ConversationChrome+SheetRowLabel.

extension SheetRow {
    var sheetRowLeading: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).atlasSans(17).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if let sub {
                Text(sub).atlasSans(13).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}
