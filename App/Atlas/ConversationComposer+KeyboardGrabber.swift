import SwiftUI
import AtlasCore

// Keyboard grabber — peel de ConversationComposer+QueueGrabber.
// Bar → ConversationComposer+KeyboardGrabber+Bar.swift
// Gestures → ConversationComposer+KeyboardGrabber+Gestures.swift

extension ConversationComposer {
    @ViewBuilder
    var keyboardGrabber: some View {
        if focused.wrappedValue {
            keyboardGrabberGestures(keyboardGrabberBar)
        }
    }
}
