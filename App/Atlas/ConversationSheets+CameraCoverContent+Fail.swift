import SwiftUI
import AtlasCore

// Camera capture fail — peel de ConversationSheets+CameraCoverContent.

extension ConversationCameraCoverModifier {
    func cameraCoverOnCaptureFailed() {
        model.toast = CameraPickerA11y.captureFailedToast
    }
}
