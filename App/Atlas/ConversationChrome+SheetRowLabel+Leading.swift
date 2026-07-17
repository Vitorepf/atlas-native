import SwiftUI

// Sheet row leading — peel de ConversationChrome+SheetRowLabel.

extension SheetRow {
    var sheetRowLeading: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if let sub {
                Text(sub).font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}
