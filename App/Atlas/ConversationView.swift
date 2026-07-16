import SwiftUI
import PhotosUI
import AtlasCore

// A conversa — a base da comunicação. Metáfora de PÁGINA EDITORIAL, não bolhas
// SaaS: o turno do operador é uma citação com barra bronze; o do Atlas é uma
// página cheia (markdown editorial) com assinatura de provider, feedback
// governado e streaming vivo. Composer com placeholder serif, foco gold e
// pills geral·auto. Tudo respeitando Reduce Motion.
struct ConversationView: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AtlasSession.self) private var session
    @State private var model: ConversationModel
    @State private var draft = ""
    @State private var mode = "geral"
    @State private var showModeSheet = false
    @State private var showWorkspaceSheet = false
    @State private var showQueueSheet = false
    @State private var reviewTrace: ReviewTraceRef?

    struct ReviewTraceRef: Identifiable { let id: TraceID }
    @State private var showAttachmentSheet = false
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var showFileImporter = false
    @State private var showCamera = false
    @FocusState private var focused: Bool
    @State private var awayFromBottom = false
    /// F2.8: coalescer scroll durante streaming (tokens) — anima se >100ms
    /// desde o último ou se a contagem de bolhas mudou.
    @State private var lastScrollAt: CFAbsoluteTime = 0
    @State private var lastScrollBubbleCount = 0

    // Anexo presente = card aberto: sem isso, anexar com o composer colapsado
    // deixava o operador sem botão de enviar (a fileira de controles só existia
    // com o teclado aberto). Estado de composição ⊃ estado de foco.
    private var expanded: Bool { focused || !model.drafts.isEmpty }

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
        _draft = State(initialValue: draft)
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
        _model = State(initialValue: model)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                cacheAgeSeal
                messages
            }
            composer
        }
        .navigationBarHidden(true)
        .overlay(alignment: .top) { toast }
        .task { await model.load() }
        // Presença fora do app: Live Activity (lock screen/Dynamic Island)
        // enquanto trabalha + notificação local quando conclui fora da tela.
        .onAppear {
            TurnPresence.shared.watch(model, threadTitle: title, threadId: model.threadId)
            if startFocused && model.bubbles.isEmpty {
                // pequeno atraso: o push da navegação precisa assentar antes
                // do foco, senão o iOS engole o teclado
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { focused = true }
            }
        }
        .onChange(of: model.threadId) { _, now in
            TurnPresence.shared.watch(model, threadTitle: title, threadId: now)
            if let now { onThread?(now) }
        }
        .onChange(of: model.isSending) { was, now in
            // Resposta terminou → haptic de sucesso (o toque que fecha o ciclo)
            if was && !now { UINotificationFeedbackGenerator().notificationOccurred(.success) }
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
            StaleReadSeal(capturedAt: capturedAt)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 2)
                .padding(.bottom, 8)
                .transition(.opacity)
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
                            EditorialTurn(bubble: bubble, reduceMotion: reduceMotion,
                                          onFeedback: { kind in Task { await model.feedback(bubble.id, kind) } },
                                          onCopy: { copy(bubble.text, label: bubble.role == "user" ? "mensagem" : "resposta") },
                                          onStop: { model.cancel() },
                                          onExecutionChoice: { jobId, optionId in
                                              Task { await model.resolveExecutionChoice(jobId: jobId, optionId: optionId) }
                                          },
                                          onRetry: { jobId in
                                              Task { await model.retryTurn(jobId: jobId) }
                                          })
                            .equatable()
                            .id(bubble.id)
                            // C15: revisão só entra pela projeção canônica do
                            // trace (a folha diz "sem artefatos" quando não há).
                            if bubble.role == "assistant", !bubble.streaming,
                               !bubble.activities.isEmpty, let trace = bubble.traceId {
                                Button { reviewTrace = ReviewTraceRef(id: trace) } label: {
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

    // MARK: - Composer elevado

    // O composer é uma superfície de escrita, não uma barra de ferramentas.
    // Ele só revela anexos e contexto quando o operador pede; o repouso fica
    // deliberadamente silencioso.
    private var composer: some View {
        VStack(alignment: .leading, spacing: 0) {
            composerCard
        }
        .animation(.easeOut(duration: 0.25), value: model.isSending)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    /// Turno vivo (streaming) — dirige a faixa de execução dentro do composer.
    private var liveBubble: ChatBubble? { model.bubbles.last(where: { $0.streaming }) }

    private var composerCard: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
            // Execução em curso: UMA linha discreta dentro do próprio card —
            // nunca um segundo elemento empilhado. O campo continua aberto:
            // escrever durante a execução é direito do operador.
            if let live = liveBubble {
                ExecutingStrip(bubble: live, reduceMotion: reduceMotion) { model.cancel() }
                    .padding(.top, expanded ? 0 : 4)
                    .padding(.bottom, expanded ? 0 : 8)
                    .transition(.opacity)
                Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
                    .padding(.bottom, expanded ? 0 : 8)
            }
            // C11: mensagens mandadas durante a execução viram FILA (o model
            // enfileira sozinho). O chip só existe quando a fila existe —
            // nada inventado; tocar abre a folha com enviar-agora e remover.
            if !model.queuedMessages.isEmpty {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    showQueueSheet = true
                } label: {
                    Text("Fila \(model.queuedMessages.count)")
                        .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.accent)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Capsule().fill(AtlasTheme.goldVeil)
                            .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                }
                .buttonStyle(PressableScale())
                .padding(.bottom, expanded ? 0 : 8)
                .transition(.opacity)
                .accessibilityLabel("\(model.queuedMessages.count) mensagens na fila, toque para gerenciar")
            }
            if focused {
                // Grabber → PUXE pra baixo (ou toque) para fechar o teclado.
                // Área de toque generosa (padding antes do contentShape) + drag.
                RoundedRectangle(cornerRadius: 3)
                    .fill(AtlasTheme.textTertiary.opacity(0.55))
                    .frame(width: 42, height: 5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .contentShape(Rectangle())
                    .onTapGesture { dismissKeyboard() }
                    .gesture(
                        DragGesture(minimumDistance: 6)
                            .onEnded { if $0.translation.height > 8 { dismissKeyboard() } }
                    )
                    .accessibilityLabel("fechar teclado")
                    .accessibilityAddTraits(.isButton)
            }
            // Strip de anexos (o contrato de UI é o LocalDraft, nada mais)
            if !model.drafts.isEmpty {
                DraftStrip(drafts: model.drafts, reduceMotion: reduceMotion,
                           onRemove: { model.removeDraft($0) },
                           onFailedTap: { model.toast = $0 })
            }
            if let p = model.uploadPercent {
                HStack(spacing: 10) {
                    ProgressView(value: p).tint(AtlasTheme.accent)
                    Text("\(Int(p * 100))%")
                        .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("enviando anexos, \(Int(p * 100)) por cento")
            }

            HStack(spacing: 10) {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    showAttachmentSheet = true
                } label: {
                    Image(systemName: "paperclip")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(PressableScale())
                .accessibilityLabel("adicionar anexo")
                ZStack(alignment: .topLeading) {
                    Text(model.bubbles.isEmpty ? "Escreva ao Atlas" : "Continuar com Atlas")
                        .font(AtlasFont.serifItalic(expanded ? 20 : 18)).foregroundStyle(AtlasTheme.textTertiary)
                        .allowsHitTesting(false).opacity(draft.isEmpty ? 1 : 0).offset(y: expanded ? 0 : -1)
                        .animation(.easeOut(duration: 0.28), value: draft.isEmpty)
                    TextField("", text: $draft, axis: .vertical)
                        .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                        .tint(AtlasTheme.accent).lineLimit(1...6).focused($focused)
                        .accessibilityIdentifier(A11yID.conversationInput)
                }
                composerTrailingControl
            }
        }
        .padding(expanded ? EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
                          : EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background(composerSurface)
        .animation(.spring(response: 0.4, dampingFraction: 0.86), value: expanded)
        .animation(.spring(response: 0.4, dampingFraction: 0.86), value: model.drafts)
        .sheet(isPresented: $showModeSheet) { ModeSheet(selected: $mode) }
        .sheet(item: $reviewTrace) { ref in
            ChangeReviewSheet(reviews: model.reviews, traceId: ref.id)
        }
        .sheet(isPresented: $showQueueSheet) {
            SheetShell(title: "Fila · \(model.queuedMessages.count)") {
                ForEach(model.queuedMessages) { m in
                    HStack(spacing: 12) {
                        Text(m.text)
                            .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button { Task { await model.promote(id: m.id) } } label: {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AtlasTheme.accent)
                                .frame(width: 38, height: 38)
                                .background(Circle().fill(AtlasTheme.goldVeil))
                        }
                        .buttonStyle(PressableScale())
                        .accessibilityLabel("enviar agora: \(m.text)")
                        Button { Task { await model.removeQueued(id: m.id) } } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundStyle(AtlasTheme.textSecondary)
                                .frame(width: 38, height: 38)
                                .background(Circle().fill(AtlasTheme.surfaceHi))
                        }
                        .buttonStyle(PressableScale())
                        .accessibilityLabel("remover da fila: \(m.text)")
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .onChange(of: model.queuedMessages.isEmpty) { _, empty in
            if empty { showQueueSheet = false }
        }
        // Recibo do handoff (status ready) → "pronto para abrir no destino".
        // O destino abre a MESMA thread; nada de sessão/histórico novos.
        .onChange(of: model.latestSurfaceHandoff?.id) {
            guard let h = model.latestSurfaceHandoff, h.status == "ready" else { return }
            let destino = h.toSurface == "atlas_desktop" ? "Mac"
                        : h.toSurface == "atlas_terminal" ? "Terminal" : h.toSurface
            model.toast = "Pronto para abrir no \(destino) — mesma conversa, mesma sessão."
        }
        .sheet(isPresented: $showAttachmentSheet) {
            ComposerAttachmentsSheet(
                pickedPhoto: $pickedPhoto,
                onChooseFile: { showFileImporter = true },
                onChooseCamera: { showCamera = true },
                onPaste: { model.addClipboard(text: $0) }
            )
        }
        .sheet(isPresented: $showWorkspaceSheet) {
            WorkspaceSheet(workspaces: session.workspaces, current: model.workspaceName) { ws in
                // Escolha REAL: slug/name/path entram no payload do próximo envio.
                model.workspaceSlug = ws.id
                model.workspaceName = ws.name
                model.workspacePath = session.workspaceFullPath(forKey: ws.id)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { data in
                model.addImage(data: data, suggestedName: nil,
                               mimeType: "image/jpeg",
                               identity: UUID().uuidString, source: "camera")
            }
            .ignoresSafeArea()
        }
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.pdf, .text, .sourceCode, .json, .commaSeparatedText]) { result in
            if case .success(let url) = result { model.addFile(url: url) }
        }
        .onChange(of: pickedPhoto) {
            guard let item = pickedPhoto else { return }
            pickedPhoto = nil
            Task {
                guard let data = try? await item.loadTransferable(type: Data.self) else {
                    model.toast = "não consegui ler a foto"; return
                }
                let mime = item.supportedContentTypes.first?.preferredMIMEType ?? "image/jpeg"
                model.addImage(data: data, suggestedName: nil, mimeType: mime,
                               identity: item.itemIdentifier ?? UUID().uuidString)
            }
        }
    }

    @ViewBuilder private var composerSurface: some View {
        if expanded || liveBubble != nil {
            // Com execução viva o card cresce em cartão (capsule de 2 linhas
            // deformaria); a borda dourada continua reservada ao foco.
            RoundedRectangle(cornerRadius: 26, style: .continuous).fill(AtlasTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(expanded ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
        } else {
            Capsule(style: .continuous).fill(AtlasTheme.surface)
                .overlay(Capsule(style: .continuous).stroke(AtlasTheme.separator, lineWidth: 1))
        }
    }

    private var composerCanSubmit: Bool {
        (!draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !model.drafts.isEmpty)
            && !model.isSending
    }

    // Contexto fica atrás de uma única ação real. O modo, o esforço e o
    // workspace continuam disponíveis, sem disputar a atenção da escrita.
    @ViewBuilder private var composerTrailingControl: some View {
        if model.isSending {
            BreathingDiamond(size: 13, reduceMotion: reduceMotion)
                .frame(width: 32, height: 32)
                .accessibilityLabel("Atlas processando")
        } else if composerCanSubmit {
            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 29))
                    .foregroundStyle(AtlasTheme.accent)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("enviar ao Atlas")
        } else {
            Menu {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    showWorkspaceSheet = true
                } label: {
                    Label("Workspace: \(model.workspaceName ?? "Atlas")", systemImage: "square.grid.2x2")
                }
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    showModeSheet = true
                } label: {
                    Label("Modo: \(mode.capitalized)", systemImage: "slider.horizontal.3")
                }
                Button {
                    model.cycleEffort()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    Label("Esforço: \(model.effort.shortLabel)", systemImage: "gauge.with.dots.needle.33percent")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
            }
            .accessibilityLabel("opções da conversa")
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

    private func dismissKeyboard() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) { focused = false }
    }

    private func send() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let text = draft
        draft = ""
        let effort = model.effort
        Task { await model.send(text, effort: effort) }
    }

    private func copy(_ text: String, label: String) {
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(AtlasMotion.editorial) { model.toast = "\(label) copiada" }
    }
}

// MARK: - Um turno (usuário = citação; Atlas = página)

// Distância do marcador de fim da conversa ao topo global (FAB de retorno).
private struct BottomDistanceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

private struct StaleReadSeal: View {
    let capturedAt: Date

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 60)) { context in
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 10, weight: .semibold))
                Text("visto há \(atlasRelativeAgePT(since: capturedAt, now: context.date))")
                    .font(AtlasFont.mono(11))
            }
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("histórico salvo visto há \(atlasRelativeAgePT(since: capturedAt, now: context.date))")
        }
    }
}

private func atlasRelativeAgePT(since date: Date, now: Date = Date()) -> String {
    let seconds = max(0, Int(now.timeIntervalSince(date)))
    if seconds < 60 { return "menos de 1 min" }

    let minutes = seconds / 60
    if minutes < 60 { return "\(minutes) min" }

    let hours = minutes / 60
    if hours < 24 { return "\(hours)h" }

    let days = hours / 24
    return days == 1 ? "1 dia" : "\(days) dias"
}
