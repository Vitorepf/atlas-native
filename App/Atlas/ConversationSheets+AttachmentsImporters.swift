import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// File importer + photo change — peel de ConversationSheets+Attachments.

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentImporters<Content: View>(on content: Content) -> some View {
        content
            .conversationCameraCover(model: model, showCamera: $showCamera)
            .fileImporter(isPresented: $showFileImporter,
                          allowedContentTypes: [.pdf, .text, .sourceCode, .json, .commaSeparatedText]) { result in
                if case .success(let url) = result { model.addFile(url: url) }
            }
            .onChange(of: pickedPhoto) {
                handlePickedPhotoChange()
            }
    }
}
