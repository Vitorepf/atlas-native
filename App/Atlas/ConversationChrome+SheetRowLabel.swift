import SwiftUI

// Sheet row label — peel de ConversationChrome+SheetRow.

extension SheetRow {
    var rowLabel: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                if let sub {
                    Text(sub).font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            Spacer()
            if selected {
                Image(systemName: "checkmark").font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 24).padding(.vertical, 15).contentShape(Rectangle())
    }
}
