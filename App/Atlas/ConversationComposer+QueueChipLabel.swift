import SwiftUI
import AtlasCore

// Queue chip label — peel de ConversationComposer+QueueGrabber.

extension ConversationComposer {
    var queueChipLabelView: some View {
        Text(queueChipLabel)
            .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.accent)
            .padding(.horizontal, 12).padding(.vertical, 5)
            .background(Capsule().fill(AtlasTheme.goldVeil)
                .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
    }
}
