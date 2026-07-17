import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Photo onChange — peel de ConversationSheets+Attachments.

extension ConversationComposerSheetsModifier {
    func handlePickedPhotoChange() {
        guard let item = pickedPhoto else { return }
        pickedPhoto = nil
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                model.toast = "não consegui ler a foto"; return
            }
            let mime = item.supportedContentTypes.first?.preferredMIMEType ?? "image/jpeg"
            model.addImage(data: data, suggestedName: nil, mimeType: mime,
                           identity: item.itemIdentifier ?? UUID().uuidString)
        }
    }
}
