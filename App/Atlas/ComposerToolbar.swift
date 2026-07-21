import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused

// --- ComposerToolbar.swift ---
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
        toolbarRow
    }
}

