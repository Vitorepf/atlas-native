import SwiftUI
import AtlasCore

// Camera fullScreenCover — peel de ConversationSheets+Modifier (CICLO C honesty).

extension View {
    func conversationCameraCover(model: ConversationModel, showCamera: Binding<Bool>) -> some View {
        modifier(ConversationCameraCoverModifier(model: model, showCamera: showCamera))
    }
}

private struct ConversationCameraCoverModifier: ViewModifier {
    var model: ConversationModel
    @Binding var showCamera: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $showCamera) {
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
}
