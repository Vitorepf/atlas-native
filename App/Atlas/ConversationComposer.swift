import SwiftUI
import PhotosUI
import AtlasCore

// Composer da conversa — peel de ConversationView (régua anti-inchaço).
// Superfície de escrita + AttachmentStrip + ComposerToolbar + fila + execução.
// Callbacks e A11yIDs idênticos; zero mudança de rota.

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

    // Anexo presente = card aberto: sem isso, anexar com o composer colapsado
    // deixava o operador sem botão de enviar (a fileira de controles só existia
    // com o teclado aberto). Estado de composição ⊃ estado de foco.
    var expanded: Bool { focused.wrappedValue || !model.drafts.isEmpty }

    /// Turno vivo (streaming) — dirige a faixa de execução dentro do composer.
    var liveBubble: ChatBubble? { model.bubbles.last(where: { $0.streaming }) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            composerCard
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: model.isSending)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private var composerCard: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
            liveExecutionSection
            queueChipSection
            keyboardGrabber
            AttachmentStrip(
                drafts: model.drafts,
                reduceMotion: reduceMotion,
                uploadPercent: model.uploadPercent,
                onRemove: { model.removeDraft($0) },
                onFailedTap: { model.toast = $0 }
            )
            ComposerToolbar(
                model: model,
                reduceMotion: reduceMotion,
                focused: focused,
                expanded: expanded,
                mode: mode,
                liveBubble: liveBubble,
                onAttach: { showAttachmentSheet = true },
                onShowWorkspace: { showWorkspaceSheet = true },
                onShowMode: { showModeSheet = true },
                onShowEffort: { showEffortSheet = true },
                onSend: send
            )
        }
        .padding(expanded ? EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
                          : EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background(composerSurface)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: expanded)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: model.drafts)
        .conversationComposerSheets(
            model: model,
            session: session,
            mode: $mode,
            showModeSheet: $showModeSheet,
            showWorkspaceSheet: $showWorkspaceSheet,
            showEffortSheet: $showEffortSheet,
            showQueueSheet: $showQueueSheet,
            showAttachmentSheet: $showAttachmentSheet,
            showCamera: $showCamera,
            showFileImporter: $showFileImporter,
            pickedPhoto: $pickedPhoto,
            reviewTrace: $reviewTrace,
            artifactTrace: $artifactTrace,
            steerTrace: $steerTrace,
            onSteerSubmit: submitSteer
        )
    }
}
