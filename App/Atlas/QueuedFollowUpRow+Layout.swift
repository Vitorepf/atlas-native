import SwiftUI

// Row chrome — peel de QueuedFollowUpRow.

extension QueuedFollowUpRow {
    var rowLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            rowText
            promoteButton
            removeButton
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .accessibilityIdentifier(A11yID.queueRow(index))
        .overlay(alignment: .bottom) {
            Divider().overlay(AtlasTheme.separator).padding(.leading, 24)
                .accessibilityHidden(true)
        }
    }
}
