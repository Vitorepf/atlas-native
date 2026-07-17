import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Attachments + photo importer — peel de ConversationSheets+Modifier.
// Photo → ConversationSheets+AttachmentsPhoto.swift

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentModifiers<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showAttachmentSheet) {
                ComposerAttachmentsSheet(
                    pickedPhoto: $pickedPhoto,
                    onChooseFile: { showFileImporter = true },
                    onChooseCamera: { showCamera = true },
                    onPaste: { model.addClipboard(text: $0) }
                )
            }
            .sheet(isPresented: $showWorkspaceSheet) {
                WorkspaceSheet(workspaces: session.workspaces, current: model.workspaceName) { ws in
                    model.workspaceSlug = ws.id
                    model.workspaceName = ws.name
                    model.workspacePath = session.workspaceFullPath(forKey: ws.id)
                }
            }
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
