import SwiftUI

/// Remove queue button — peel de QueuedFollowUpRow+Buttons.

extension QueuedFollowUpRow {
    var removeButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRemove()
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 38, height: 38)
                .background(Circle().fill(AtlasTheme.surfaceHi))
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(removeLabel)
        .accessibilityHint(removeHint)
        .accessibilityIdentifier(A11yID.queueRemove(message.id))
    }
}
