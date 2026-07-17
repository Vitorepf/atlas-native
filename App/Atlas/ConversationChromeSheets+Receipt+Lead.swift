import SwiftUI
import AtlasCore

// Icon — peel de ConversationHandoffReceipt.
// Copy → ConversationChromeSheets+Receipt+CopyStack.swift

extension ConversationHandoffReceipt {
    var receiptIcon: some View {
        Image(systemName: isReady ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isReady ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .symbolEffect(.rotate, isActive: isPending && !reduceMotion)
            .accessibilityHidden(true)
    }
}
