import SwiftUI
import PhotosUI
import UIKit

// Paste + file options — peel de ComposerAttachmentsSheet+Options.
// Paste → ConversationChrome+ComposerAttachmentsSheet+PasteButton.swift
// FileOption → ConversationChrome+ComposerAttachmentsSheet+Paste+FileOption.swift

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentFileAndPaste: some View {
        attachmentFileOption
        pasteButton
    }

    func choose(_ action: @escaping @MainActor () -> Void) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
        Task { @MainActor in action() }
    }
}
