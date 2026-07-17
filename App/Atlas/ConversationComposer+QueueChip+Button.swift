import SwiftUI
import AtlasCore

// Queue chip button — peel de ConversationComposer+QueueGrabber.
// A11y → ConversationComposer+QueueChip+A11y.swift

extension ConversationComposer {
    @ViewBuilder
    var queueChipButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            showQueueSheet = true
        } label: {
            queueChipLabelView
        }
        .buttonStyle(PressableScale())
    }
}
