import SwiftUI
import AtlasCore

// Camera fullScreenCover — peel de ConversationSheets+Modifier (CICLO C honesty).
// Modifier → ConversationSheets+CameraCoverModifier.swift

extension View {
    func conversationCameraCover(model: ConversationModel, showCamera: Binding<Bool>) -> some View {
        modifier(ConversationCameraCoverModifier(model: model, showCamera: showCamera))
    }
}
