import SwiftUI
import AtlasCore

// Camera capture — peel de ConversationSheets+CameraCoverContent.

extension ConversationCameraCoverModifier {
    func cameraCoverOnCapture(data: Data) {
        model.addImage(
            data: data,
            suggestedName: nil,
            mimeType: "image/jpeg",
            identity: UUID().uuidString,
            source: "camera"
        )
    }
}
