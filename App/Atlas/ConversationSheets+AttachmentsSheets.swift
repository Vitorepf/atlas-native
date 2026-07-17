import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Attachment sheet — peel de ConversationSheets+Attachments.
// Workspace → ConversationSheets+AttachmentsWorkspace.swift
// Picker → ConversationSheets+AttachmentsSheets+Picker.swift

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentSheets<Content: View>(on content: Content) -> some View {
        workspacePickerSheet(on:
            attachmentPickerSheet(on: content)
        )
    }
}
