import SwiftUI

/// Botões promote/remove — peel de QueuedFollowUpRow+Actions.

extension QueuedFollowUpRow {
    var promoteButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onPromote()
        } label: {
            Image(systemName: "arrow.up")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 38, height: 38)
                .background(Circle().fill(AtlasTheme.goldVeil))
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(promoteLabel)
        .accessibilityHint(promoteHint)
        .accessibilityIdentifier(A11yID.queuePromote(message.id))
    }

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
