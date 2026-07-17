import SwiftUI
import PhotosUI
import UIKit

// Paste action — peel de ComposerAttachmentsSheet+PasteButton.
// A11y → ConversationChrome+ComposerAttachmentsSheet+Paste+A11y.swift

extension ComposerAttachmentsSheet {
    func pasteButtonAction() {
        guard let text = pasteboardText else { return }
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
        Task { @MainActor in onPaste(text) }
    }
}
