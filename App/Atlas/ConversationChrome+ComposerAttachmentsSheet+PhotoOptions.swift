import SwiftUI
import PhotosUI
import UIKit

// Attachment photo/camera options — peel de ComposerAttachmentsSheet+Options.
// Photo → ConversationChrome+ComposerAttachmentsSheet+PhotoOptions+Photo.swift
// Camera → ConversationChrome+ComposerAttachmentsSheet+PhotoOptions+Camera.swift

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentPhotoOptions: some View {
        attachmentPhotoOption
        attachmentCameraOption
    }
}
