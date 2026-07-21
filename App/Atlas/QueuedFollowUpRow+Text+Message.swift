import SwiftUI

// Message preview — peel de QueuedFollowUpRow+Text.

extension QueuedFollowUpRow {
    var rowMessagePreview: some View {
        Text(message.text)
            .font(AtlasFont.serif(16))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(2)
            .accessibilityHidden(true)
    }
}
