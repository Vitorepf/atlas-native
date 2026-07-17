import SwiftUI

// Message preview — peel de QueuedFollowUpRow+Text.

extension QueuedFollowUpRow {
    var rowMessagePreview: some View {
        Text(message.text)
            .font(.system(.callout))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(2)
            .accessibilityHidden(true)
    }
}
