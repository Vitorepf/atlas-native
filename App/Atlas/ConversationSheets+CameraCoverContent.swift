import SwiftUI
import AtlasCore

// Camera cover content — peel de ConversationSheets+CameraCoverModifier.
// A11y → ConversationSheets+CameraCoverA11y.swift

extension ConversationCameraCoverModifier {
    var cameraCoverContent: some View {
        cameraCoverA11y(
            CameraPicker(
                onCapture: { data in
                    model.addImage(
                        data: data,
                        suggestedName: nil,
                        mimeType: "image/jpeg",
                        identity: UUID().uuidString,
                        source: "camera"
                    )
                },
                onCaptureFailed: { model.toast = CameraPickerA11y.captureFailedToast },
                onCancel: {}
            )
        )
    }
}
