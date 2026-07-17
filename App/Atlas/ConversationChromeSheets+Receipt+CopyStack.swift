import SwiftUI
import AtlasCore

// Handoff receipt copy — peel de ConversationChromeSheets+Receipt+Lead.

extension ConversationHandoffReceipt {
    var receiptCopy: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(headline)
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subline)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}
