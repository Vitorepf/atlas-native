import SwiftUI
import AtlasCore

// Camera cover modifier — peel de ConversationSheets+CameraCover.
// Content → ConversationSheets+CameraCoverContent.swift

struct ConversationCameraCoverModifier: ViewModifier {
    var model: ConversationModel
    @Binding var showCamera: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $showCamera) {
                cameraCoverContent
            }
    }
}
