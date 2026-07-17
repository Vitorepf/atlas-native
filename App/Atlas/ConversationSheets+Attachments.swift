import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Attachments + photo importer — peel de ConversationSheets+Modifier.
// Photo → ConversationSheets+AttachmentsPhoto.swift
// Importers → ConversationSheets+AttachmentsImporters.swift

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentModifiers<Content: View>(on content: Content) -> some View {
        attachmentImporters(on:
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
        )
    }
}
