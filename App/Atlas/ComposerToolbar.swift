import SwiftUI
import AtlasCore

// Toolbar do composer: paperclip + campo + trailing (enviar / processando / menu
// de modo·esforço·workspace). Peel de ConversationComposer (régua <200).
// Field → ComposerToolbar+Field.swift
// CanSubmit → ComposerToolbar+CanSubmit.swift

struct ComposerToolbar: View {
    var model: ConversationModel
    var reduceMotion: Bool
    var focused: FocusState<Bool>.Binding
    var expanded: Bool
    var mode: String
    var liveBubble: ChatBubble?
    var onAttach: () -> Void
    var onShowWorkspace: () -> Void
    var onShowMode: () -> Void
    var onShowEffort: () -> Void
    var onSend: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            attachButton
            composerTextField
            trailingControl
        }
        .accessibilityElement(children: .contain)
    }
}
