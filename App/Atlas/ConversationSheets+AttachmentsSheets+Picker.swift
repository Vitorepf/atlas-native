import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Attachment picker sheet — peel de ConversationSheets+AttachmentsSheets.

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentPickerSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showAttachmentSheet) {
                ComposerAttachmentsSheet(
                    pickedPhoto: $pickedPhoto,
                    onChooseFile: { showFileImporter = true },
                    onChooseCamera: { showCamera = true },
                    onPaste: { model.addClipboard(text: $0) }
                )
            }
    }
}
