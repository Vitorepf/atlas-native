import SwiftUI
import PhotosUI
import UIKit

/// Opções da folha de anexos — peel de ComposerAttachmentsSheet (régua ≤100).
/// Paste → ConversationChrome+ComposerAttachmentsSheet+Paste.swift
/// Photo → ConversationChrome+ComposerAttachmentsSheet+PhotoOptions.swift

extension ComposerAttachmentsSheet {
    var pasteboardText: String? {
        UIPasteboard.general.string?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty
    }

    @ViewBuilder var attachmentOptions: some View {
        attachmentPhotoOptions
        attachmentFileAndPaste
    }
}
