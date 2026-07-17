import SwiftUI

// Queue row text — peel de QueuedFollowUpRow.

extension QueuedFollowUpRow {
    var rowText: some View {
        VStack(alignment: .leading, spacing: 4) {
            if total > 1 {
                Text(positionCaption)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(index == 0 ? AtlasTheme.accent : AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Text(message.text)
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowSpokenLabel)
    }
}
