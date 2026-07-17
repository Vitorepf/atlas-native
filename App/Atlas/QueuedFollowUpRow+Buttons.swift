import SwiftUI

/// Promote button — peel de QueuedFollowUpRow+Actions.
/// Remove → QueuedFollowUpRow+Remove.swift

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
}
