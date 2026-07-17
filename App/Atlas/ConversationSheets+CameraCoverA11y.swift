import SwiftUI
import AtlasCore

// Camera cover a11y — peel de ConversationSheets+CameraCoverContent.

extension ConversationCameraCoverModifier {
    func cameraCoverA11y<Content: View>(_ content: Content) -> some View {
        content
            .ignoresSafeArea()
            .accessibilityIdentifier(A11yID.cameraPicker)
            .accessibilityLabel(CameraPickerA11y.spokenSurface)
            .accessibilityHint(CameraPickerA11y.spokenHint)
            .transaction { txn in
                if reduceMotion { txn.disablesAnimations = true }
            }
    }
}
