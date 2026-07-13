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
    @State private var effort: AtlasComputeEffort = .auto
    @State private var mode = "geral"
    @State private var showModeSheet = false
    @State private var showWorkspaceSheet = false
    @State private var pickedPhoto: PhotosPickerItem?
    @FocusState private var focused: Bool

    // Contador de tokens (estimativa live do rascunho ≈ chars/4), como o desktop.
    private var draftTokens: Int { Int(ceil(Double(draft.count) / 4.0)) }

    // Anexo presente = card aberto: sem isso, anexar com o composer colapsado
    // deixava o operador sem botão de enviar (a fileira de controles só existia
    // com o teclado aberto). Estado de composição ⊃ estado de foco.
    private var expanded: Bool { focused || !model.drafts.isEmpty }

    init(client: AtlasClient, threadId: String?, title: String) {
        self.title = title
        _model = State(initialValue: ConversationModel(client: client, threadId: threadId))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                messages
            }
            composer
        }
        .navigationBarHidden(true)
        .overlay(alignment: .top) { toast }
        .task { await model.load() }
        .onAppear { effort = ComposerPrefs.effort }
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
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 4)
    }

    // MARK: - Turnos (página editorial)

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if model.bubbles.isEmpty {
                    EmptyConversation(reduceMotion: reduceMotion)
                } else {
                    LazyVStack(alignment: .leading, spacing: 40) {
                        ForEach(model.bubbles) { bubble in
                            EditorialTurn(bubble: bubble, reduceMotion: reduceMotion,
                                          onFeedback: { kind in Task { await model.feedback(bubble.id, kind) } },
                                          onCopy: { copy(bubble.text, label: bubble.role == "user" ? "mensagem" : "resposta") },
                                          onStop: { model.cancel() })
                            .id(bubble.id)
                        }
                        Color.clear.frame(height: 96).id("bottom")
                    }
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 16)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: model.bubbles) {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    // MARK: - Composer elevado

    // Composer: colapsado = pill minimalista (ultra-premium). Ao focar, expande no
    // CARD do app base (papel pousando): placeholder serif grande + linha de
    // controles (anexo · geral · auto · voz · mic), borda dourada.
    private var composer: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
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
            if expanded {
                // Header: seletor de workspace (real) + contador de tokens (como o desktop)
                HStack(spacing: 6) {
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        showWorkspaceSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(model.workspaceName ?? "Atlas")
                                .font(.system(size: 14, weight: .medium)).foregroundStyle(AtlasTheme.textSecondary)
                            Text("main").font(.system(size: 14)).foregroundStyle(AtlasTheme.textTertiary)
                            Image(systemName: "chevron.down").font(.system(size: 10, weight: .semibold)).foregroundStyle(AtlasTheme.textTertiary)
                        }
                    }
                    .buttonStyle(PressableScale())
                    Spacer()
                    Text("\(draftTokens) tokens")
                        .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
                }
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
                if !expanded {
                    PhotosPicker(selection: $pickedPhoto, matching: .images) {
                        Image(systemName: "paperclip").font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 30, height: 30)
                    }
                    .accessibilityLabel("anexar foto")
                }
                ZStack(alignment: .topLeading) {
                    Text(model.bubbles.isEmpty ? "Escreva ao Atlas" : "Continuar com Atlas")
                        .font(AtlasFont.serifItalic(expanded ? 20 : 18)).foregroundStyle(AtlasTheme.textTertiary)
                        .allowsHitTesting(false).opacity(draft.isEmpty ? 1 : 0).offset(y: expanded ? 0 : -1)
                        .animation(.easeOut(duration: 0.28), value: draft.isEmpty)
                    TextField("", text: $draft, axis: .vertical)
                        .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                        .tint(AtlasTheme.accent).lineLimit(1...6).focused($focused)
                }
                if !expanded {
                    Button { model.toast = "ditado por voz — em breve" } label: {
                        Image(systemName: "mic.fill").font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 30, height: 30)
                    }.buttonStyle(.plain)
                    .accessibilityLabel("ditado por voz, em breve")
                }
            }

            if expanded {
                HStack(spacing: 8) {
                    PhotosPicker(selection: $pickedPhoto, matching: .images) {
                        Image(systemName: "paperclip").font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 30, height: 30)
                    }
                    .accessibilityLabel("anexar foto")
                    pill(label: mode) {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred(); showModeSheet = true
                    }
                    pill(label: effort.shortLabel) {
                        effort = effort.next
                        ComposerPrefs.effort = effort
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
                    if draft.isEmpty {
                        controlIcon("headphones") { model.toast = "voz em tempo real — em breve" }
                    }
                    Spacer()
                    sendOrMic
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(expanded ? EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
                          : EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background(composerSurface)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.86), value: expanded)
        .animation(.spring(response: 0.4, dampingFraction: 0.86), value: model.drafts)
        .sheet(isPresented: $showModeSheet) { ModeSheet(selected: $mode) }
        .sheet(isPresented: $showWorkspaceSheet) {
            WorkspaceSheet(workspaces: session.workspaces, current: model.workspaceName) { ws in
                // Escolha REAL: slug/name/path entram no payload do próximo envio.
                model.workspaceSlug = ws.id
                model.workspaceName = ws.name
                model.workspacePath = session.workspaceFullPath(forKey: ws.id)
            }
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
        if expanded {
            RoundedRectangle(cornerRadius: 26, style: .continuous).fill(AtlasTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(AtlasTheme.goldBorder, lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
        } else {
            Capsule(style: .continuous).fill(AtlasTheme.surface)
                .overlay(Capsule(style: .continuous).stroke(AtlasTheme.separator, lineWidth: 1))
        }
    }

    private func controlIcon(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 30, height: 30)
        }
        .buttonStyle(PressableScale())
    }

    // Slot de 3 estados HONESTOS: enviando → losango respirando (Atlas
    // trabalhando, nada clicável); pode enviar → seta gold; vazio → mic.
    // (Antes, durante o envio aparecia o mic — controle falso.)
    private var sendOrMic: some View {
        let canSubmit = (!draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                         || !model.drafts.isEmpty) && !model.isSending
        return ZStack {
            if model.isSending {
                BreathingDiamond(size: 13, reduceMotion: reduceMotion)
                    .accessibilityLabel("Atlas processando")
            } else {
                Image(systemName: "mic.fill")
                    .font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary)
                    .opacity(canSubmit ? 0 : 1).allowsHitTesting(!canSubmit)
                Button(action: send) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 27)).foregroundStyle(AtlasTheme.accent)
                }
                .buttonStyle(.plain)
                .opacity(canSubmit ? 1 : 0).allowsHitTesting(canSubmit)
                .accessibilityLabel("enviar ao Atlas")
            }
        }
        .frame(width: 30, height: 30)
        .animation(.easeOut(duration: 0.28), value: canSubmit)
        .animation(.easeOut(duration: 0.28), value: model.isSending)
    }

    private func pill(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Circle().fill(AtlasTheme.accent.opacity(0.95)).frame(width: 5.5, height: 5.5)
                Text(label).font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.textSecondary)
            }
            .padding(.horizontal, 11).padding(.vertical, 6)
            .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
        }
        .buttonStyle(PressableScale())
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
        let effort = self.effort
        Task { await model.send(text, effort: effort) }
    }

    private func copy(_ text: String, label: String) {
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(AtlasMotion.editorial) { model.toast = "\(label) copiada" }
    }
}

// MARK: - Um turno (usuário = citação; Atlas = página)

private struct EditorialTurn: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    let onCopy: () -> Void
    let onStop: () -> Void
    @State private var placed = false

    var body: some View {
        Group {
            if bubble.role == "user" {
                Text("“\(bubble.text)”")
                    .font(AtlasFont.serifItalic(18)).lineSpacing(8).foregroundStyle(AtlasTheme.textPrimary)
                    .padding(.leading, 16)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    if bubble.streaming {
                        ExecutionRibbon(bubble: bubble, reduceMotion: reduceMotion, onStop: onStop)
                    }
                    if !bubble.text.isEmpty {
                        AtlasMarkdownView(text: bubble.text)
                    }
                    if !bubble.streaming {
                        SignatureLine(provider: bubble.provider, model: bubble.model, elapsedMs: bubble.elapsedMs)
                        FeedbackRow(active: bubble.feedbackAction, onFeedback: onFeedback)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onLongPressGesture(minimumDuration: 0.38) { onCopy() }
            }
        }
        .opacity(placed ? 1 : 0)
        .offset(y: placed ? 0 : 12)
        .onAppear {
            if reduceMotion { placed = true }
            else { withAnimation(AtlasMotion.arrival) { placed = true } }
        }
    }
}

// A assinatura sussurrada: "— claude-sonnet-4-6, em 6,6 s" — o MODELO exato +
// duração (Cursor esconde o modelo). Fraunces italic, atrasada 220ms.
private struct SignatureLine: View {
    let provider: String?
    let model: String?
    let elapsedMs: Int?
    @State private var shown = false
    var body: some View {
        Text(signature)
            .font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.textPrimary.opacity(0.4))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(shown ? 1 : 0)
            .task {
                try? await Task.sleep(nanoseconds: 220_000_000)
                withAnimation(.easeIn(duration: 0.28)) { shown = true }
            }
    }
    private var signature: String {
        let who = (model?.isEmpty == false && !(model ?? "").hasSuffix("_default")) ? model! : providerWord(provider)
        if let ms = elapsedMs, ms > 0 { return "— \(who), em \(humanDuration(ms))" }
        return "— \(who)"
    }
}

func humanDuration(_ ms: Int) -> String {
    if ms < 1000 { return "um instante" }
    if ms < 60000 { return String(format: "%.1f s", Double(ms) / 1000).replacingOccurrences(of: ".", with: ",") }
    return "\(ms / 60000) min"
}

// Feedback dirigido — treina o roteamento (o que Cursor/Codex não têm).
private struct FeedbackRow: View {
    let active: String?
    let onFeedback: (FeedbackKind) -> Void
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FeedbackKind.allCases) { kind in
                let isActive = active == kind.activeAction
                Button { onFeedback(kind) } label: {
                    Text(isActive ? "\(kind.label) ✓" : kind.label)
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(isActive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .overlay(Capsule().stroke(isActive ? AtlasTheme.domAutonomos.opacity(0.5) : AtlasTheme.separator, lineWidth: 1))
                }
                .buttonStyle(PressableScale())
            }
            Spacer()
        }
        .padding(.top, 2)
    }
}

// A RIBBON DE EXECUÇÃO — o diferencial vs Cursor. Mostra AO VIVO: quanto tempo,
// a ORQUESTRA (cada agente/provider/modelo + status), o estágio do Atlas Decide,
// e um botão Stop. Cursor mostra 1 agente; o Atlas mostra a máquina inteira.
private struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                BreathingDiamond(size: 14, reduceMotion: reduceMotion)
                TimelineView(.periodic(from: .now, by: 1)) { ctx in
                    Text(statusLabel(now: ctx.date))
                        .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textSecondary)
                }
                Spacer()
                Button(action: onStop) {
                    Image(systemName: "stop.fill").font(.system(size: 10))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .frame(width: 26, height: 26).background(Circle().fill(AtlasTheme.surfaceHi))
                }.buttonStyle(.plain)
            }
            if !bubble.agents.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(bubble.agents) { AgentRow(agent: $0) }
                }.padding(.leading, 24)
            }
            if let strat = bubble.decideStrategy {
                Text("atlas decide · \(strat)" + (bubble.decideStage.map { " → \($0)" } ?? ""))
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).padding(.leading, 24)
            }
        }
        .padding(.vertical, 10).padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.surface.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        )
    }
    private func statusLabel(now: Date) -> String {
        let secs = bubble.startedAt.map { max(0, Int(now.timeIntervalSince($0))) } ?? 0
        let working = bubble.agents.contains { $0.status == "processing" } || !bubble.text.isEmpty
        return "\(working ? "Trabalhando" : "Pensando") \(secs)s"
    }
}

private struct AgentRow: View {
    let agent: ExecAgent
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(statusColor).frame(width: 6, height: 6)
            Text(agent.agent ?? providerWord(agent.provider))
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textSecondary)
            if let m = agent.model, !m.isEmpty, !m.hasSuffix("_default") {
                Text(m).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
            }
            Spacer()
            Text(statusWord).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textTertiary)
        }
    }
    private var statusColor: Color {
        switch agent.status {
        case "processing": return AtlasTheme.accent
        case "succeeded": return AtlasTheme.domAutonomos
        case "failed", "cancelled": return AtlasTheme.domOperacional
        default: return AtlasTheme.textTertiary
        }
    }
    private var statusWord: String {
        switch agent.status {
        case "queued": return "na fila"
        case "processing": return "processando"
        case "succeeded": return "pronto"
        case "failed": return "falhou"
        case "cancelled": return "cancelado"
        case "awaiting_user_choice": return "aguardando"
        default: return agent.status
        }
    }
}

// Losango bronze respirando (SyncDiamond) — a resposta viva.
private struct BreathingDiamond: View {
    let size: CGFloat
    let reduceMotion: Bool
    @State private var on = false
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(AtlasTheme.accent)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(45))
            .scaleEffect(on ? 1.18 : 1)
            .opacity(on ? 0.45 : 1)
            .onAppear { if !reduceMotion { withAnimation(AtlasMotion.breath(0.9)) { on = true } } else { on = false } }
    }
}

// Botão com press-scale spring (tato físico).
struct PressableScale: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(configuration.isPressed ? .easeOut(duration: 0.12) : .spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// claude_cli → "claude", conselho → "conselho", etc.
func providerWord(_ p: String?) -> String {
    guard let p, !p.isEmpty else { return "atlas" }
    let x = p.lowercased()
    for (k, v) in [("claude", "claude"), ("codex", "codex"), ("gemini", "gemini"),
                   ("hermes", "hermes"), ("minimax", "minimax"),
                   ("council", "conselho"), ("conselho", "conselho")] where x.contains(k) {
        return v
    }
    return x
}

// Empty state vivo: a pergunta contemplativa ✦
private struct EmptyConversation: View {
    let reduceMotion: Bool
    @State private var breathe = false
    var body: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(32)).foregroundStyle(AtlasTheme.accent)
                .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
                .scaleEffect(breathe ? 1.06 : 1).opacity(breathe ? 0.85 : 1)
            Spacer().frame(height: 40)
            Text("“O que você quer pensar agora?”")
                .font(AtlasFont.serifItalic(22)).lineSpacing(10)
                .multilineTextAlignment(.center).foregroundStyle(AtlasTheme.textPrimary)
        }
        .padding(.horizontal, 32).padding(.top, 140)
        .frame(maxWidth: .infinity)
        .onAppear { if !reduceMotion { withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { breathe = true } } }
    }
}

// MARK: - Strip de anexos do composer

// A strip renderiza LocalDraft e nada mais (contrato único de UI de anexos).
// Estados legíveis: pronto (borda sutil), subindo (véu + spinner), falhou
// (borda vermelha + ⚠; tocar mostra o motivo). ✕ com alvo de 44pt.
private struct DraftStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(drafts) { d in
                    DraftThumb(draft: d, onRemove: onRemove, onFailedTap: onFailedTap)
                        .transition(reduceMotion ? .opacity
                                    : .scale(scale: 0.86).combined(with: .opacity))
                }
            }
            .padding(.top, 6).padding(.trailing, 6)
        }
        .scrollClipDisabled()   // o ✕ vaza do thumb; sem isto o clip corta o alvo
    }
}

private struct DraftThumb: View {
    let draft: LocalDraft
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    private var failedMessage: String? {
        if case .falhou(let m) = draft.state { return m }
        return nil
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            thumb
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(failedMessage != nil ? AtlasTheme.domOperacional.opacity(0.8) : AtlasTheme.separator,
                            lineWidth: failedMessage != nil ? 1.5 : 1))
                .overlay { stateVeil }
                .onTapGesture { if let m = failedMessage { onFailedTap("falhou: \(m)") } }

            if draft.state != .subindo {
                Button { onRemove(draft.id) } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AtlasTheme.textPrimary, AtlasTheme.bgRecessed)
                        .padding(8)          // alvo ~44pt sem crescer o ícone
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .offset(x: 12, y: -12)
                .accessibilityLabel("remover \(draft.fileName)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(a11yLabel)
    }

    @ViewBuilder private var thumb: some View {
        if draft.kind == .image, let data = draft.preview, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            VStack(spacing: 4) {
                Image(systemName: "doc.fill").font(.system(size: 20)).foregroundStyle(AtlasTheme.textSecondary)
                Text((draft.fileName as NSString).pathExtension.uppercased())
                    .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AtlasTheme.surfaceHi)
        }
    }

    @ViewBuilder private var stateVeil: some View {
        if draft.state == .subindo {
            ZStack { ProgressView().tint(.white) }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.38))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else if failedMessage != nil {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AtlasTheme.domOperacional)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(6)
        }
    }

    private var a11yLabel: String {
        let mb = String(format: "%.1f", Double(draft.bytes) / 1_048_576)
        let state: String
        switch draft.state {
        case .pronto: state = "pronto para enviar"
        case .subindo: state = "enviando"
        case .falhou: state = "falhou, toque para ver o motivo"
        }
        return "anexo \(draft.fileName), \(mb) megabytes, \(state)"
    }
}

// MARK: - Sheets (seletores funcionais, tema Atlas)

private struct SheetShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3).fill(AtlasTheme.textTertiary.opacity(0.5))
                .frame(width: 40, height: 5).padding(.top, 10).padding(.bottom, 16)
            Text(title).font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary).padding(.bottom, 14)
            ScrollView { VStack(spacing: 0) { content } }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(AtlasTheme.bg.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationBackground(AtlasTheme.bg)
        .presentationDragIndicator(.hidden)
    }
}

private struct SheetRow: View {
    let label: String
    var sub: String? = nil
    let selected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary)
                    if let sub { Text(sub).font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary) }
                }
                Spacer()
                if selected { Image(systemName: "checkmark").font(.system(size: 15, weight: .semibold)).foregroundStyle(AtlasTheme.accent) }
            }
            .padding(.horizontal, 24).padding(.vertical, 15).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}

private struct ModeSheet: View {
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss
    private let modes = [
        ("geral", "Geral", "conversa e raciocínio amplos"),
        ("operacional", "Operacional", "tarefas do dia, decisões, execução"),
        ("autônomos", "Autônomos", "obras longas, agentes em background"),
        ("programação", "Programação", "código em um ou vários repos"),
    ]
    var body: some View {
        SheetShell(title: "Modo") {
            ForEach(modes, id: \.0) { key, label, sub in
                SheetRow(label: label, sub: sub, selected: key == selected) {
                    selected = key; UIImpactFeedbackGenerator(style: .soft).impactOccurred(); dismiss()
                }
            }
        }
    }
}

private struct WorkspaceSheet: View {
    let workspaces: [Workspace]
    let current: String?
    let onPick: (Workspace) -> Void
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        SheetShell(title: "Workspace") {
            if workspaces.isEmpty {
                Text("Nenhum workspace ainda").font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary).padding(.top, 40)
            } else {
                ForEach(workspaces) { ws in
                    SheetRow(label: ws.name, sub: "\(ws.count) conversas · main", selected: ws.name == current) {
                        onPick(ws); UIImpactFeedbackGenerator(style: .soft).impactOccurred(); dismiss()
                    }
                }
            }
        }
    }
}
