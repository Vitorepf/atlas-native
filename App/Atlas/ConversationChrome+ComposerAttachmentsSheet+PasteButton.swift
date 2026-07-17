import SwiftUI
import PhotosUI
import UIKit

// Paste button — peel de ComposerAttachmentsSheet+Paste.
// Label → ConversationChrome+ComposerAttachmentsSheet+PasteLabel.swift

extension ComposerAttachmentsSheet {
    @ViewBuilder var pasteButton: some View {
        Button {
            guard let text = pasteboardText else { return }
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
            Task { @MainActor in onPaste(text) }
        } label: {
            pasteButtonLabel
        }
        .buttonStyle(.plain)
        .disabled(pasteboardText == nil)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenPaste(hasText: pasteboardText != nil))
        .accessibilityHint(pasteboardText == nil
            ? ComposerAttachmentsA11y.spokenPasteDisabledHint
            : ComposerAttachmentsA11y.spokenPasteHint)
        .accessibilityIdentifier(A11yID.attachmentPaste)
    }
}
