import SwiftUI
import AtlasCore

// Camera cover content — peel de ConversationSheets+CameraCoverModifier.

extension ConversationCameraCoverModifier {
    var cameraCoverContent: some View {
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
        .ignoresSafeArea()
        .accessibilityIdentifier(A11yID.cameraPicker)
        .accessibilityLabel(CameraPickerA11y.spokenSurface)
        .accessibilityHint(CameraPickerA11y.spokenHint)
        .transaction { txn in
            if reduceMotion { txn.disablesAnimations = true }
        }
    }
}
