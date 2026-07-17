import SwiftUI

struct QueuedFollowUpRow: View {
    let message: QueuedMessage
    let index: Int
    let total: Int
    let onPromote: () -> Void
    let onRemove: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
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
