import SwiftUI
import AtlasCore

// Queue chip — peel de ConversationComposer+LiveStrip.
// Grabber → ConversationComposer+KeyboardGrabber.swift
// Label → ConversationComposer+QueueChipLabel.swift
// Button → ConversationComposer+QueueChip+Button.swift
// A11y → ConversationComposer+QueueChip+A11y.swift

extension ConversationComposer {
    @ViewBuilder
    var queueChipSection: some View {
        if !model.queuedMessages.isEmpty {
            queueChipA11y(queueChipButton)
        }
    }
}
