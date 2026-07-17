import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Attachment sheet — peel de ConversationSheets+Attachments.
// Workspace → ConversationSheets+AttachmentsWorkspace.swift

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentSheets<Content: View>(on content: Content) -> some View {
        workspacePickerSheet(on:
            content
                .sheet(isPresented: $showAttachmentSheet) {
                    ComposerAttachmentsSheet(
                        pickedPhoto: $pickedPhoto,
                        onChooseFile: { showFileImporter = true },
                        onChooseCamera: { showCamera = true },
                        onPaste: { model.addClipboard(text: $0) }
                    )
                }
        )
    }
}
