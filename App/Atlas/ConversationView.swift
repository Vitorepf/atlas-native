import SwiftUI
import PhotosUI
import AtlasCore

// A conversa — a base da comunicação. Metáfora de PÁGINA EDITORIAL, não bolhas
// SaaS: o turno do operador é uma citação com barra bronze; o do Atlas é uma
// página cheia (markdown editorial) com assinatura de provider, feedback
// governado e streaming vivo. Composer: ConversationComposer.swift.
// Turnos: ConversationMessages.swift. Folhas: ConversationSheets.swift.
// Chrome: ConversationViewChrome.swift.
struct ConversationView: View {
    let title: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) private var session
    @State var model: ConversationModel
    @State private var mode = "geral"
    @State private var showModeSheet = false
    @State private var showWorkspaceSheet = false
    @State private var showQueueSheet = false
    @State var showOutline = false
    @State private var reviewTrace: ConversationReviewTraceRef?
    @State private var artifactTrace: ConversationReviewTraceRef?
    @State private var steerTrace: ConversationSteerTraceRef?
    @State private var showAttachmentSheet = false
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var showFileImporter = false
    @State private var showCamera = false
    @FocusState var focused: Bool
    @State private var awayFromBottom = false
    @State var readSealConfirming = false
    @State var lastCacheCapturedAt: Date?
    /// F2.8: coalescer scroll durante streaming (tokens) — anima se >100ms
    /// desde o último ou se a contagem de bolhas mudou.
    @State private var lastScrollAt: CFAbsoluteTime = 0
    @State private var lastScrollBubbleCount = 0

    // Conversa nova (sem thread) abre com o teclado JÁ de pé — chegou, falou.
    private let startFocused: Bool

    /// O convite do estado vazio. A conversa do Atlas pergunta o que você quer
    /// pensar; a do Código pergunta sobre o repositório aberto. Mesma máquina,
    /// assunto diferente — não é tela nova, é a mesma com outro chamado.
    private let emptyPrompt: String?
    private let emptySuggestions: [String]?
    /// A thread real, assim que o servidor a confirma. Quem apresenta esta view
    /// numa folha precisa guardá-la: fechar a folha destrói o model, e sem isto
    /// reabrir começaria do zero — a conversa existiria no servidor e não na
    /// tela, que é a pior das duas verdades.
    private let onThread: ((ThreadID) -> Void)?

    init(
        client: AtlasClient,
        threadId: ThreadID?,
        title: String,
        emptyPrompt: String? = nil,
        emptySuggestions: [String]? = nil,
        taskKind: String? = nil,
        workspace: String? = nil,
        draft: String = "",
        turnFacts: ((String) async -> String?)? = nil,
        onThread: ((ThreadID) -> Void)? = nil
    ) {
        self.title = title
        self.startFocused = threadId == nil
        // Pergunta semeada por quem abriu (ex.: a folha do commit): o operador
        // chega com o assunto escrito e edita se quiser. Semear NÃO é enviar —
        // mandar sozinho seria decidir por ele.
        self.emptyPrompt = emptyPrompt
        self.emptySuggestions = emptySuggestions
        self.onThread = onThread
        let model = ConversationModel(client: client, threadId: threadId)
        model.turnFacts = turnFacts
        model.taskKind = taskKind
        if let workspace {
            model.workspaceSlug = workspace
            model.workspaceName = workspace
        }
        if !draft.isEmpty {
            model.updateDraft(draft)
        }
        _model = State(initialValue: model)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                cacheAgeSeal
                handoffReceipt
                ConversationMessages(
                    model: model,
                    reduceMotion: reduceMotion,
                    emptyPrompt: emptyPrompt,
                    emptySuggestions: emptySuggestions,
                    awayFromBottom: $awayFromBottom,
                    lastScrollAt: $lastScrollAt,
                    lastScrollBubbleCount: $lastScrollBubbleCount,
                    reviewTrace: $reviewTrace,
                    artifactTrace: $artifactTrace,
                    steerTrace: $steerTrace,
                    onEditResend: editAndResend,
                    onCopy: copy
                )
            }
            ConversationComposer(
                model: model,
                session: session,
                reduceMotion: reduceMotion,
                focused: $focused,
                mode: $mode,
                showModeSheet: $showModeSheet,
                showWorkspaceSheet: $showWorkspaceSheet,
                showQueueSheet: $showQueueSheet,
                showAttachmentSheet: $showAttachmentSheet,
                pickedPhoto: $pickedPhoto,
                showFileImporter: $showFileImporter,
                showCamera: $showCamera,
                reviewTrace: $reviewTrace,
                artifactTrace: $artifactTrace,
                steerTrace: $steerTrace
            )
        }
        .navigationBarHidden(true)
        .overlay(alignment: .top) { toast }
        .task { await model.load() }
        // Presença fora do app: Live Activity (lock screen/Dynamic Island)
        // enquanto trabalha + notificação local quando conclui fora da tela.
        .onAppear {
            TurnPresence.shared.watch(model, threadTitle: title, threadId: model.threadId)
            TurnPresence.shared.setVisible(model, visible: true)
            if startFocused && model.bubbles.isEmpty {
                // pequeno atraso: o push da navegação precisa assentar antes
                // do foco, senão o iOS engole o teclado
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { focused = true }
            }
        }
        .onChange(of: model.threadId) { _, now in
            TurnPresence.shared.watch(model, threadTitle: title, threadId: now)
            TurnPresence.shared.setVisible(model, visible: true)
            if let now { onThread?(now) }
        }
        .onDisappear {
            TurnPresence.shared.setVisible(model, visible: false)
            model.markThreadVisited()
        }
        .onChange(of: model.isSending) { was, now in
            // Resposta terminou → haptic de sucesso (o toque que fecha o ciclo)
            if was && !now { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        }
        .onChange(of: model.cacheCapturedAt) { _, capturedAt in
            if let capturedAt { lastCacheCapturedAt = capturedAt }
        }
        .sheet(isPresented: $showOutline) {
            ConversationOutlineSheet(bubbles: model.bubbles)
        }
        .onChange(of: model.showingStaleCache) { was, now in
            if now, let capturedAt = model.cacheCapturedAt {
                lastCacheCapturedAt = capturedAt
            } else if was && !now, lastCacheCapturedAt != nil {
                readSealConfirming = true
            }
        }
    }
}
