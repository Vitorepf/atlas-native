import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Attachments + photo importer — peel de ConversationSheets+Modifier.
// Photo → ConversationSheets+AttachmentsPhoto.swift
// Importers → ConversationSheets+AttachmentsImporters.swift
// Sheets → ConversationSheets+AttachmentsSheets.swift

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentModifiers<Content: View>(on content: Content) -> some View {
        attachmentImporters(on: attachmentSheets(on: content))
    }
}
