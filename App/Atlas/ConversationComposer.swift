import SwiftUI
import AtlasCore
import PhotosUI

// IDLE-COMPRESS host

struct ConversationComposer: View {
    var model: ConversationModel
    var session: AtlasSession
    var reduceMotion: Bool
    var focused: FocusState<Bool>.Binding

    @Binding var mode: String
    @Binding var showModeSheet: Bool
    @Binding var showWorkspaceSheet: Bool
    @Binding var showEffortSheet: Bool
    @Binding var showQueueSheet: Bool
    @Binding var showAttachmentSheet: Bool
    @Binding var pickedPhoto: PhotosPickerItem?
    @Binding var showFileImporter: Bool
    @Binding var showCamera: Bool
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            composerCard
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: model.isSending)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(composerFadeBackground)
    }

    // Anexo presente = card aberto: sem isso, anexar com o composer colapsado
    // deixava o operador sem botão de enviar. Estado de composição ⊃ estado de foco.
    var expanded: Bool { focused.wrappedValue || !model.drafts.isEmpty }

    /// Turno vivo (streaming) — dirige a faixa de execução dentro do composer.
    var liveBubble: ChatBubble? { model.bubbles.last(where: { $0.streaming }) }

    var composerFadeBackground: some View {
        LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

