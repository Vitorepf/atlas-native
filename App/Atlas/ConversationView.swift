import SwiftUI
import PhotosUI
import AtlasCore

// A conversa — a base da comunicação. Metáfora de PÁGINA EDITORIAL, não bolhas
// SaaS: o turno do operador é uma citação com barra bronze; o do Atlas é uma
// página cheia (markdown editorial) com assinatura de provider, feedback
// governado e streaming vivo. Composer: ConversationComposer.swift.
// Folhas/chrome de apresentação: ConversationSheets.swift.
struct ConversationView: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AtlasSession.self) private var session
    @State private var model: ConversationModel
    @State private var mode = "geral"
    @State private var showModeSheet = false
    @State private var showWorkspaceSheet = false
    @State private var showQueueSheet = false
    @State private var showOutline = false
    @State private var reviewTrace: ConversationReviewTraceRef?
    @State private var artifactTrace: ConversationReviewTraceRef?
    @State private var steerTrace: ConversationSteerTraceRef?
    @State private var showAttachmentSheet = false
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var showFileImporter = false
    @State private var showCamera = false
    @FocusState private var focused: Bool
    @State private var awayFromBottom = false
    @State private var readSealConfirming = false
    @State private var lastCacheCapturedAt: Date?
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
                messages
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

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            Spacer()
            Text(title).font(AtlasFont.serif(17, .semibold)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            Spacer()
            // Continuidade: a MESMA thread/sessão continua em outra superfície.
            // Só para conversa canônica; o "pronto" só aparece com o recibo.
            if model.threadId != nil {
                Menu {
                    Button { showOutline = true } label: {
                        Label("Índice da conversa", systemImage: "list.bullet.rectangle")
                    }
                    Button {
                        Task { await model.handoffToSurface(.desktop) }
                    } label: { Label("Continuar no Mac", systemImage: "desktopcomputer") }
                    Button {
                        Task { await model.handoffToSurface(.terminal) }
                    } label: { Label("Continuar no Terminal", systemImage: "terminal") }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(AtlasTheme.textSecondary)
                        .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
                }
                .accessibilityLabel("continuar esta conversa em outra superfície")
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 4)
    }

    @ViewBuilder private var cacheAgeSeal: some View {
        if model.showingStaleCache, let capturedAt = model.cacheCapturedAt {
            StaleReadSeal(capturedAt: capturedAt, confirming: false, reduceMotion: reduceMotion)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 2)
                .padding(.bottom, 8)
                .transition(.opacity)
        } else if readSealConfirming, let capturedAt = lastCacheCapturedAt {
            StaleReadSeal(capturedAt: capturedAt, confirming: true, reduceMotion: reduceMotion)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 2)
                .padding(.bottom, 8)
                .transition(.opacity)
                .task {
                    try? await Task.sleep(nanoseconds: 320_000_000)
                    readSealConfirming = false
                }
        }
    }

    // MARK: - Turnos (página editorial)

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if model.bubbles.isEmpty {
                    EmptyConversation(
                        reduceMotion: reduceMotion,
                        prompt: emptyPrompt,
                        suggestions: emptySuggestions
                    ) { suggestion in
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        let effort = model.effort
                        Task { await model.send(suggestion, effort: effort) }
                    }
                } else {
                    LazyVStack(alignment: .leading, spacing: 40) {
                        ForEach(model.bubbles) { bubble in
                            if bubble.id == model.firstNewBubbleId {
                                NewSinceLastVisitMarker()
                                    .id("new-since-last-visit")
                            }
                            let traceArtifacts = bubble.traceId.flatMap { model.reviews.artifactsByTrace[$0] }
                            let artifactItems = traceArtifacts?.state == .available ? traceArtifacts?.items ?? [] : []
                            EditorialTurn(bubble: bubble, reduceMotion: reduceMotion,
                                          onFeedback: { kind in Task { await model.feedback(bubble.id, kind) } },
                                          onCopy: { copy(bubble.text, label: bubble.role == "user" ? "mensagem" : "resposta") },
                                          onEditResend: { editAndResend(bubble) },
                                          onStop: { model.cancel() },
                                          onExecutionChoice: { jobId, optionId in
                                              Task { await model.resolveExecutionChoice(jobId: jobId, optionId: optionId) }
                                          },
                                          onRetry: { jobId in
                                              Task { await model.retryTurn(jobId: jobId) }
                                          },
                                          onSteer: { trace in steerTrace = ConversationSteerTraceRef(id: trace) },
                                          artifactItems: artifactItems,
                                          onOpenArtifacts: { trace in artifactTrace = ConversationReviewTraceRef(id: trace) })
                            .equatable()
                            .id(bubble.id)
                            .task(id: bubble.traceId?.rawValue) {
                                if bubble.role == "assistant", !bubble.streaming, let trace = bubble.traceId {
                                    await model.reviews.refreshArtifacts(traceId: trace)
                                }
                            }
                            // C15: revisão só entra pela projeção canônica do
                            // trace (a folha diz "sem artefatos" quando não há).
                            if bubble.role == "assistant", !bubble.streaming,
                               !bubble.activities.isEmpty, let trace = bubble.traceId {
                                Button { reviewTrace = ConversationReviewTraceRef(id: trace) } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.forwardslash.minus").font(.system(size: 11))
                                        Text("Revisar mudanças").font(.system(.footnote, weight: .medium))
                                    }
                                    .foregroundStyle(AtlasTheme.textSecondary)
                                    .padding(.horizontal, 13).padding(.vertical, 7)
                                    .background(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
                                }
                                .buttonStyle(PressableScale())
                                .accessibilityHint("abre arquivos, diff e provas desta execução")
                            }
                        }
                        Color.clear.frame(height: 96).id("bottom")
                            .background(GeometryReader { geo in
                                Color.clear.preference(key: BottomDistanceKey.self,
                                                       value: geo.frame(in: .global).minY)
                            })
                    }
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 16)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onPreferenceChange(BottomDistanceKey.self) { minY in
                // marcador abaixo da dobra + margem → operador navegou pra cima
                awayFromBottom = minY > UIScreen.main.bounds.height + 140
            }
            .overlay(alignment: .bottomTrailing) {
                if awayFromBottom {
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    } label: {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AtlasTheme.surfaceHi)
                                .overlay(Circle().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                                .shadow(color: .black.opacity(0.25), radius: 8, y: 2))
                    }
                    .buttonStyle(PressableScale())
                    .padding(.trailing, AtlasTheme.Space.screen).padding(.bottom, 110)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .accessibilityLabel("ir para o fim da conversa")
                }
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: awayFromBottom)
            .onChange(of: model.bubbles) {
                let count = model.bubbles.count
                let now = CFAbsoluteTimeGetCurrent()
                let countChanged = count != lastScrollBubbleCount
                guard countChanged || now - lastScrollAt >= 0.1 else { return }
                lastScrollAt = now
                lastScrollBubbleCount = count
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Toast editorial

    @ViewBuilder private var toast: some View {
        if let t = model.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    withAnimation(AtlasMotion.editorial) { model.toast = nil }
                }
        }
    }

    @ViewBuilder private var handoffReceipt: some View {
        if let handoff = model.latestSurfaceHandoff {
            ConversationHandoffReceipt(handoff: handoff)
        }
    }

    private func editAndResend(_ bubble: ChatBubble) {
        guard bubble.role == "user" else { return }
        model.updateDraft(bubble.text)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        withAnimation(AtlasMotion.editorial) {
            focused = true
            model.toast = "mensagem no composer para novo turno"
        }
    }

    private func copy(_ text: String, label: String) {
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(AtlasMotion.editorial) { model.toast = "\(label) copiada" }
    }
}

// Distância do marcador de fim da conversa ao topo global (FAB de retorno).
private struct BottomDistanceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
