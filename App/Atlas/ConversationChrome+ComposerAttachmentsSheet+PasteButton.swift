import SwiftUI
import PhotosUI
import UIKit

// Paste button — peel de ComposerAttachmentsSheet+Paste.
// Label → ConversationChrome+ComposerAttachmentsSheet+PasteLabel.swift
// Action → ConversationChrome+ComposerAttachmentsSheet+Paste+Action.swift
// A11y → ConversationChrome+ComposerAttachmentsSheet+Paste+A11y.swift

extension ComposerAttachmentsSheet {
    @ViewBuilder var pasteButton: some View {
        pasteButtonA11y(
            Button {
                pasteButtonAction()
            } label: {
                pasteButtonLabel
            }
            .buttonStyle(.plain)
        )
    }
}
