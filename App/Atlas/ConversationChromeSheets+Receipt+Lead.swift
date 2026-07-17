import SwiftUI
import AtlasCore

// Icon + copy — peel de ConversationHandoffReceipt.

extension ConversationHandoffReceipt {
    var receiptIcon: some View {
        Image(systemName: isReady ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isReady ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .symbolEffect(.rotate, isActive: isPending && !reduceMotion)
            .accessibilityHidden(true)
    }

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
